require 'sinatra'
enable :sessions

configure do
  set :session_secret, "My session secret"
  set :aportes, {}
end

helpers do
    
  def title
    @title || "Repartija"
  end
  
  def Set_aportes(uno, dos)
    settings.aportes[uno.to_sym] ||= dos
  end

  def Get_aportes()
    return @aportes
  end

end

get '/' do
  erb :form
end

post '/' do
  @title = "Resultado"
  @nombre = params[:nombre].chomp
  Set_aportes(@nombre, params[:cantidad].to_i)
  @ap = settings.aportes
  puts @ap
  if session[@nombre.to_sym].nil?
    session[@nombre.to_sym] = params[:cantidad].to_i
    puts session
  end

  @finished = params[:finished]
  if @finished 
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
  
  <p> Nombre:</p>
  <p><%= @ap %></p>
  <p>Resultado:</p>
  <p><%= session[:Jorge] %></p>
