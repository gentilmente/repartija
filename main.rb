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
  set :aportes, {}
  set :ocupado, false
end

helpers do
  def title
    @title || "Repartija"
  end
  
  def set_aportes(nombre, pago)
    settings.aportes[nombre.to_sym] ||= pago
  end

  def hard_code_aportes()
    settings.aportes = { 
      Bufarra: 0, 
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
    #puts
    #puts "Total: " 
    #puts @total 
    #puts "Pago individual: " 
    #puts @pago_individual
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

  def calcular(acreedores, deudores)
    @resultados = {}
    acreedores.each do |acreedor, monto_acr|
      @monto_acr_actual = monto_acr
      @acumulado = 0
      puts'-------------------------------------------------------------------------'
      puts "Para acreedor: " + acreedor.to_s + monto_acr.to_s
      deudores.each  do |deudor, deuda| 
        #puts "    " + deudor.to_s + " debe: " + deuda.to_s
        #puts "    monto_acr_actual: " + @monto_acr_actual.to_s
        #puts "    monto_acr: " + monto_acr.to_s
        if(deuda > 0 && @monto_acr_actual < 0)
          @acumulado += deuda
          @resta_pagar = @acumulado + monto_acr
          #puts "acumulado: " + @acumulado.to_s
          #puts "resta_pagar: " + @resta_pagar.to_s
          puts "el deudor: " + deudor.to_s

          if( @resta_pagar > 0 && @resta_pagar < @pago_individual)
            puts "Paga: " + (deuda - @resta_pagar).to_s
            deudores[deudor] = @resta_pagar
            acreedores[acreedor] += deuda - @resta_pagar
            @monto_acr_actual = acreedores[acreedor]
            generar_salida(acreedor, deudor, deuda - @resta_pagar)

          elsif (deuda < @pago_individual)
            puts "ppaga: " + deuda.to_s
            deudores[deudor] = 0
            acreedores[acreedor] += deuda
            @monto_acr_actual = acreedores[acreedor]
            generar_salida(acreedor, deudor, deuda)

          elsif (@resta_pagar <= 0)
            puts "paga: " + @pago_individual.to_s
            deudores[deudor] = 0
            acreedores[acreedor] += @pago_individual
            @monto_acr_actual = acreedores[acreedor]
            generar_salida(acreedor, deudor, @pago_individual)
          end
        end
        #puts acreedores.to_s
        #puts deudores.to_s
      end 
    end
    puts'-------------------------------------------------------------------------' 
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
  if !settings.ocupado
    settings.aportes.clear
    erb :start
  else
    erb :start
  end
end

get '/form' do
  settings.aportes.clear
  settings.ocupado = true
  erb :form
end

post '/form' do
  @title = "Resultado"
  @nombre = params[:nombre].chomp

  #====================== Para testing =================================

  set_aportes(@nombre, params[:cantidad].to_i)
  #hard_code_aportes()

  #=====================================================================

#  if session[@nombre.to_sym].nil?
#    session[@nombre.to_sym] = params[:cantidad].to_i
#    puts session
#  end

  @finished = params[:finished]
  if @finished 
    @saldos = preparar_listas(settings.aportes)
    acreedores, deudores = separar_lista(@saldos)
    @resultados = calcular(acreedores, deudores)
#    puts @resultados
#    puts @resultados.to_html
    puts HashToHTML(@resultados)
    settings.ocupado = false
    erb :result
  else
    settings.ocupado = true
    erb :form
  end
end
