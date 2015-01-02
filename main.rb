require 'bundler'
Bundler.setup
require 'sinatra'

class Hash
  def to_html
    ['<ul>',map { |k, v| ["<li>#{k}: ", v.respond_to?(:to_html) ?
     v.to_html : "<span> #{v}</span></li>"] },'</ul>'].join
  end
end

configure do
  enable :sessions
  set :session_secret, "My session secret"
  set :aportes, {}
end

helpers do
  def title
    @title || "Repartija"
  end
  
  def set_aportes(uno, dos)
    settings.aportes[uno.to_sym] ||= dos
  end

  def hard_code_aportes()
    settings.aportes = { 
      Bufarra: 40, 
      Martin: 600,  
      Joni: 150,  
      Pedro: 0,  
      Cachi: 0, 
      Gisela: 200,
      Eze: 0  
    }
  end

  def preparar_listas(aportes)
    puts
    puts "Total: " 
    puts @total = aportes.values.reduce(:+)
    puts "Pago individual: " 
    puts @pago_individual = @total/aportes.length
    return aportes.inject({}){ |hash, (k, v)| hash.merge( k.to_sym => @pago_individual - v )  }
  end

  def separar_lista(saldos)
    acreedores, deudores = saldos.partition { |_,e| e < 0 }
    acreedores = acreedores.to_h 
    deudores = deudores.to_h
    puts "acreedores: "
    puts acreedores.to_s
    puts "deudores: "
    puts deudores.to_s 
    return acreedores, deudores
  end

  def calcular(acreedores, deudores)
    @resultados = {}
    acreedores.each do |nombre_acr, monto_acr|
      @monto_acr_actual = monto_acr
      @acumulado = 0
      puts'-------------------------------------------------------------------------'
      puts "Para acreedor: " + nombre_acr.to_s + monto_acr.to_s
      deudores.each  do |k, v| 
        #puts "monto acreedor: " + monto_acr.to_s
        #puts
        if(v > 0 && @monto_acr_actual < 0)
          puts "el deudor: " + k.to_s
          @acumulado += v
          @resta_pagar = @acumulado + monto_acr
          #puts "acumulado: " + @acumulado.to_s
          #puts "resta_pagar: " + @resta_pagar.to_s
          if( @resta_pagar > 0 && @resta_pagar < @pago_individual)
            puts "Paga: " + (@pago_individual - @resta_pagar).to_s
            deudores[k] = @resta_pagar
            acreedores[nombre_acr] += @pago_individual - @resta_pagar
            @monto_acr_actual = acreedores[nombre_acr]
            if(!@resultados.has_key?(nombre_acr))
              @resultados[nombre_acr.to_sym] = {k.to_sym => @pago_individual - @resta_pagar}
            else
              @resultados[nombre_acr].store(k, @pago_individual - @resta_pagar)
            end

          elsif (v < @pago_individual)
            puts "ppaga: " + v.to_s
            deudores[k] = 0
            acreedores[nombre_acr] += v
            @monto_acr_actual = acreedores[nombre_acr]
            if(!@resultados.has_key?(nombre_acr))
              @resultados[nombre_acr.to_sym] = {k.to_sym => v}
            else
              @resultados[nombre_acr].store(k, v)
            end

          elsif (@resta_pagar <= 0)
            puts "paga: " + @pago_individual.to_s
            deudores[k] = 0
            acreedores[nombre_acr] += @pago_individual
            @monto_acr_actual = acreedores[nombre_acr]
            if(!@resultados.has_key?(nombre_acr))
              @resultados[nombre_acr.to_sym] = {k.to_sym => @pago_individual}
            else
              @resultados[nombre_acr].store(k, @pago_individual)
            end
          end
        end
        puts acreedores.to_s
        puts deudores.to_s
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
  erb :form
end

post '/' do
  @title = "Resultado"
  @nombre = params[:nombre].chomp
  #set_aportes(@nombre, params[:cantidad].to_i)
  hard_code_aportes()

#  if session[@nombre.to_sym].nil?
#    session[@nombre.to_sym] = params[:cantidad].to_i
#    puts session
#  end

  @finished = params[:finished]
  if @finished 
    @saldos = preparar_listas(settings.aportes)
    acreedores, deudores = separar_lista(@saldos)
    @resultados = calcular(acreedores, deudores)
    puts @resultados
    puts @resultados.to_html
    puts HashToHTML(@resultados)
    erb :result
  else
    erb :form
  end
end
