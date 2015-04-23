require 'bundler'
Bundler.setup
require 'sinatra'

class Hash
  def to_html
    ['<ul>',map { |k, v| ["<li>#{k}: ", v.respond_to?(:to_html) ?
     v.to_html : "<span>$ #{v}</span></li>"] },'</ul>'].join
  end
end

configure do
  enable :sessions
  set :session_secret, "My session secret"
  set :bind, '0.0.0.0' #para acceder en WLAN a la IP del server http://192.168.0.10:4567
end

helpers do
  def title
    @title || "Repartija"
  end

  def set_aportes(nombre, pago)
    session[:aportes][nombre.to_sym] ||= pago
  end

  def hard_code_aportes()
    session[:aportes] = {
      Bufarra: 40,
      Martin: 600,
      Joni: 152,
      Pedro: 0,
      Cachi: 0,
      Gisela: 200,
      Eze: 0
    }
  end

  def preparar_listas(aportes)
    @total = aportes.values.reduce(:+)
    @pago_individual = @total/aportes.length
    return aportes.inject({}){ |hash, (k, v)| hash.merge( k.to_sym => @pago_individual - v )  }
  end

  def separar_lista(saldos)
    acreedores, deudores = saldos.partition { |_,e| e < 0 }
    acreedores = acreedores.to_h
    deudores = deudores.to_h
    return acreedores, deudores
  end

  def generar_salida(acreedor, deudor, pago)
    if(!@resultados.key?(acreedor))
      @resultados[acreedor.to_sym] = {deudor.to_sym => pago}
    else
      @resultados[acreedor].store(deudor, pago)
    end
  end

  def calcular(pagos)
    saldos = preparar_listas(pagos)
    acreedores, deudores = separar_lista(saldos)
    @resultados = {}
    acreedores.each do |acreedor, monto_acr|
      @monto_acr_actual = monto_acr
      @acumulado = 0
      deudores.each  do |deudor, deuda|

        if(deuda > 0 && @monto_acr_actual < 0)
          @acumulado += deuda
          @resta_pagar = @acumulado + monto_acr

          if( @resta_pagar > 0 && @resta_pagar < @pago_individual)
            deudores[deudor] = @resta_pagar
            acreedores[acreedor] += deuda - @resta_pagar
            @monto_acr_actual = acreedores[acreedor]
            generar_salida(acreedor, deudor, deuda - @resta_pagar)

          elsif (deuda < @pago_individual)
            deudores[deudor] = 0
            acreedores[acreedor] += deuda
            @monto_acr_actual = acreedores[acreedor]
            generar_salida(acreedor, deudor, deuda)

          elsif (@resta_pagar <= 0)
            deudores[deudor] = 0
            acreedores[acreedor] += @pago_individual
            @monto_acr_actual = acreedores[acreedor]
            generar_salida(acreedor, deudor, @pago_individual)
          end
        end
      end
    end
    return @resultados
  end

  def HashToHTML(hash, opts = {})
    return if !hash.is_a?(Hash)
    indent_level = opts.fetch(:indent_level) { 0 }
    out = " " * indent_level + "<ul>\n"
    hash.each do |key, value|
      out += " " * (indent_level + 2) + "<li><strong>#{key}:</strong>"
      if value.is_a?(Hash)
        out += "\n" + HashToHTML(value, :indent_level => indent_level + 2) + " " * (indent_level + 2) + "</li>\n"
      else
        out += " <span>#{value}</span></li>\n"
      end
    end
    out += " " * indent_level + "</ul>\n"
  end
end

get '/' do
  erb :start
end

get '/form' do
  session[:aportes] ||= Hash.new
  erb :form
end

post '/form' do
  @title = "Resultado"
  @nombre = params[:nombre].chomp

  #====================== Para testing =================================

  set_aportes(@nombre, params[:cantidad].to_i)
  #hard_code_aportes()

  #=====================================================================

  @finished = params[:finished]
  if @finished
    @resultados = calcular(session[:aportes])
    @aportes = session[:aportes]
    session.clear
    erb :result
  else
    erb :form
  end
end
