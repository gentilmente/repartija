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
  
  def Set_aportes(uno, dos)
    settings.aportes[uno.to_sym] ||= dos
  end

  def Preparar_listas(aportes)
      #@aportes = [43,10,27,0,0,0,120,0,0,0]
      #puts @aportes.to_s
      puts "Total: " 
      puts @total = aportes.values.reduce(:+)
      puts "Pago individual: " 
      puts @pago_individual = @total/aportes.length
      settings.saldos = aportes.values.map {|e| @pago_individual - e }
  end

  def Separar_lista()
    settings.acreedores, settings.deudores = settings.saldos.partition { |e| e < 0 }
    puts "acreedores: "
    puts settings.acreedores.to_s
    puts "deudores: "
    puts settings.deudores.to_s 
  end

end

get '/' do
  erb :form
end

post '/' do
  @title = "Resultado"
  @nombre = params[:nombre].chomp
  Set_aportes(@nombre, params[:cantidad].to_i)

#  if session[@nombre.to_sym].nil?
#    session[@nombre.to_sym] = params[:cantidad].to_i
#    puts session
#  end

  @finished = params[:finished]
  if @finished 
    Preparar_listas(settings.aportes)
    Separar_lista()
    puts @saldos = settings.saldos
    #puts @saldos
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
    <h1>
      <a href='/'>Repartija</a>
    </h1>
    <%= yield %>
  </body>
</html>

@@form
  <form action='/' method='POST'>
    <input type='text' name ='nombre' placeholder='Escriba su  '>
    <input type='number' name ='cantidad' placeholder='0'>
    <input type='checkbox' name ='finished'>
    <input type='submit' value='enviar'>
  </form>
  
@@result

  <h3>Total: </h3> <p><%= @total %></p>
  <h4>Pago individual: </h4> <p><%=@pago_individual%><p>
  <p> Nombre:</p>
  <p><%= @ap %></p>
  <p>Saldos:</p>
  <% @saldos.each do |m| %>
  <%= m.to_s + ', '%>
  <% end %>
