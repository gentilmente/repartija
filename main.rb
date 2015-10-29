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

  def set_input(user_name, paiment)
    session[:input][user_name.to_sym] ||= paiment
  end

  def hard_code_input()
    session[:input] = {
      Bufarra: 40,
      Martin: 378,
      Joni: 110,
      Pedro: 0,
      Cachi: 0,
      Gisela: 172,
      Eze: 0
    }
  end

  def prepare_data_set(input)
    @total = input.values.reduce(:+)
    @individual_paiment = @total/input.length
    return input.inject({}) do |hash, (k, v)|
     hash.merge( k.to_sym => @individual_paiment - v )
   end
  end

  def devide_list(balance)
    creditors, debtors = balance.partition { |_,e| e < 0 }
    creditors = creditors.to_h
    debtors = debtors.to_h
    return creditors, debtors
  end

  def generate_output(creditor, debtor, paiment)
    if(!@result.key?(creditor))
      @result[creditor.to_sym] = {debtor.to_sym => paiment}
    else
      @result[creditor].store(debtor, paiment)
    end
  end

  def balance(creditor, debtor, paiment)
    @debtors[debtor] = @yet_to_pay
    @creditors[creditor] += paiment
    @actual_creditor_amount = @creditors[creditor]
    generate_output(creditor, debtor, paiment)
  end

  def pay(debtor, debt, creditor, creditor_amount)
    if(debt > 0 && @actual_creditor_amount < 0)
      @creditor_accum += debt
      @yet_to_pay = @creditor_accum + creditor_amount
      if( @yet_to_pay > 0 && @yet_to_pay < @individual_paiment)
        paiment = debt - @yet_to_pay
        balance(creditor, debtor, paiment)
      elsif (debt < @individual_paiment)
        balance(creditor, debtor, debt)
      elsif (@yet_to_pay <= 0)
        balance(creditor, debtor, @individual_paiment)
      end
    end
  end

  def collect(creditor, creditor_amount)
    @actual_creditor_amount = creditor_amount
    @creditor_accum = 0
    @debtors.each  do |debtor, debt|
      pay(debtor, debt,creditor, creditor_amount)
    end
  end

  def calculate(input)
    balance = prepare_data_set(input)
    @creditors, @debtors = devide_list(balance)
    @result = {}
    @creditors.each do |creditor, creditor_amount|
      collect(creditor, creditor_amount)
    end
    return @result
  end

  def HashToHTML(hash, opts = {})
    return if !hash.is_a?(Hash)
    indent_level = opts.fetch(:indent_level) { 0 }
    out = " " * indent_level + "<ul>\n"
    hash.each do |key, value|
      out += " " * (indent_level + 2) + "<li><strong>#{key}:</strong>"
      if value.is_a?(Hash)
        out += "\n" + HashToHTML(value, :indent_level => indent_level + 2)
        + " " * (indent_level + 2) + "</li>\n"
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
  session[:input] ||= Hash.new
  erb :form
end

post '/form' do
  @title = "Resultado"
  @user_name = params[:user_name].chomp

  #====================== Para testing =================================

  set_input(@user_name, params[:cantidad].to_i)
  #hard_code_input()

  #=====================================================================

  @finished = params[:finished]
  if @finished
    @result = calculate(session[:input])
    @input = session[:input]
    session.clear
    erb :result
  else
    erb :form
  end
end
