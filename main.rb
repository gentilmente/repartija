require 'sinatra'
require 'slim'
require 'sass'
require './song'

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
  set :cantidad, 0
end

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

get('/styles.css'){ scss :styles }

get '/' do
  slim :home
end

get '/contact' do
  slim :contact
end

not_found do
  slim :not_found
end

get '/carga' do
  slim :carga
end

post '/carga' do
  params[:username] == settings.username && params[:cantidad] == settings.password
    session[:admin] = true
  @aportes_hash = 
    redirect to('/carga')
end

get '/resultados' do
  slim :resultados
end

get '/logout' do
  session.clear
  redirect to('/login')
end

get '/set/:name' do
  session[:name] = params[:name]
end

get '/get/hello' do
  "Hello #{session[:name]}"
end