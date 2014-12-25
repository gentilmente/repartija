#require 'bundler'
#Bundler.setup
require 'sinatra'

enable :sessions

configure do
  set :session_secret, "My session secret"
  set :aportes, {}
  set :saldos, {}
  set :acreedores, {}
  set :deudores, {}
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
      "Bufarra" => 125, 
      "Martin" => 125,  
      "Joni" => 0,  
      "Pedro" => 0,  
      #{}"Cachi" => 60, 
      "Gisela" => 128,
      "Eze" => 0  
    }
  end

  def preparar_listas(aportes)
    puts "Total: " 
    puts @total = aportes.values.reduce(:+)
    puts "Pago individual: " 
    puts @pago_individual = @total/aportes.length
    puts settings.saldos = aportes.inject({}){ |hash, (k, v)| hash.merge( k.to_sym => @pago_individual - v )  }
  end

  def separar_lista()
    settings.acreedores, settings.deudores = settings.saldos.partition { |_,e| e < 0 }
    settings.acreedores = settings.acreedores.to_h 
    settings.deudores = settings.deudores.to_h
    puts "acreedores: "
    puts settings.acreedores.to_s
    puts "deudores: "
    puts settings.deudores.to_s 
  end

  def calcular()
    settings.acreedores.each do |nombre_acr, monto_acr|
      @acumulado = 0
      puts'----------------------------------------------'
      puts "\t\t\t\t\t\t\tPara acreedor: " + nombre_acr.to_s + monto_acr.to_s
      settings.deudores.each  do |k, v| 
        puts "monto acreedor: " + monto_acr.to_s
        puts
        puts "\t\t\t\t\t\t\tel deudor: " + k.to_s
        if(v > 0 && monto_acr < 0)
          @acumulado += v
          @resta_pagar = @acumulado + monto_acr
          puts "acumulado: " + @acumulado.to_s
          puts "resta_pagar: " + @resta_pagar.to_s

          if( @resta_pagar > 0 && @resta_pagar < @pago_individual)
            puts "\t\t\t\t\t\t\tPaga: " + (@pago_individual - @resta_pagar).to_s
            settings.deudores[k] = @resta_pagar
            settings.acreedores[nombre_acr] += @pago_individual - @resta_pagar

          elsif (v < @pago_individual)
            puts "\t\t\t\t\t\t\tppaga: " + v.to_s
            settings.deudores[k] = 0
            settings.acreedores[nombre_acr] += v

          elsif (@resta_pagar <= 0)
            puts "\t\t\t\t\t\t\tpaga: " + @pago_individual.to_s
            settings.deudores[k] = 0
            settings.acreedores[nombre_acr] += @pago_individual

          end
        end
        puts settings.acreedores.to_s
        puts settings.deudores.to_s
      end 
    end 
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
    preparar_listas(settings.aportes)
    separar_lista()
    calcular()
    puts @saldos = settings.saldos
    erb :result
  else
    erb :form
  end
end

##### VIEWS ######
__END__

@@layout
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title><%= title %></title>
  </head>
  <body>
    <h1><a href='/'>Repartija</a></h1>
    <%= yield %>
  </body>
</html>

@@form
  <form action='/' method='POST'>
    <input type='text' name ='nombre' placeholder='Escriba su nombre'>
    <input type='number' name ='cantidad' placeholder='0'>
    <label><input type='checkbox' name ='finished'>Listo todos</label>
    <input type='submit' value='enviar'>
  </form>
  
@@result
  <h3>Total: </h3> <p><%= @total %></p>
  <h4>Pago individual:</h4> <p><%=@pago_individual%><p>
  <p> Nombre:</p> <p><%= @nombre %></p>
  <p> Pusieron: </p> <p><%= settings.aportes %></p>

  <p>Saldos:</p>
    <% @saldos.each do |m| %>
    <%= m.to_s + ', '%>
    <% end %>
  <p>acreedores:</p>
    <% settings.acreedores.each do |key, value| %>
    <%= "#{key}: #{value}" + ', '%>
    <% end %>
  <p>deudores:</p>
    <% settings.deudores.each do |key, value| %>
    <%= "#{key}: #{value}" + ', '%>
    <% end %>


