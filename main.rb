require 'sinatra'

configure do
  enable :sessions
  set :session_secret, "My session secret"
end


helpers do
    
  def title
    @title || "Repartija"
  end
  
  def aportes
    @aportes = {}
  end

end

get '/' do
  erb :form
end

post '/' do
  @title = "Resultado"
  @nombre = params[:nombre].chomp
  if @aportes[@nombre.to_sym].nil?
    @aportes[@nombre.to_sym] = params[:cantidad].to_i
    puts 'aportes'
  end

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
    <input type='checkbox' name='termino'>
    <input type='submit' value='enviar'>
  </form>
  
@@result
  <p>nombre:</p>
  <p><%= aportes.each do |m,r| 
        puts "#{m}: #{r}"
    end %></p>
  <p>Resultado:</p>
  <p><%= aportes %></p>
