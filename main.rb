require 'sinatra'

def fill_Hash (nombre, cantidad)
  aporte = Hash.new
  aporte["nombre"]= nombre
  aporte["cant"]= cantidad
  return aporte
end

helpers do
  def title
    @title || "Repartija"
  end
  def aportes
    @aportes = []
  end
end

get '/' do
  erb :form
end

post '/' do
  @title = "Resultado"
  aportes.push( fill_Hash(params[:nombre].chomp, params[:cantidad].to_i))
  puts aportes
  @termino = params[:termino]
  if @termino 
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
    <input type='text' name='nombre' placeholder='Escriba su nombre'>
    <input type='number' name='cantidad' placeholder='0'>
    <input type='checkbox' name='termino' value='último'>
    <input type='submit' value='enviar'>
  </form>
  
@@result
  <p>nombre:</p>
  <p><%= aportes %></p>
  <p>Resultado:</p>
  <p><%= @aportes[0] %></p>
