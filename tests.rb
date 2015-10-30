require 'test/unit'
require './app.rb'

class TestRepartija < Test::Unit::TestCase
  
  def test_one
    balancer = Balancer.new
    pagos = { 
      Bufarra: 40, 
      Martin: 378,  
      Joni: 110,  
      Pedro: 0,  
      Cachi: 0, 
      Gisela: 172,
      Eze: 0  
    }

    resultados = {:Martin=>{:Bufarra=>60, 
    	:Pedro=>100, :Cachi=>100, :Eze=>18}, 
    	:Joni=>{:Eze=>10}, :Gisela=>{:Eze=>72}}

    assert_equal resultados, balancer.process(pagos)
  end   	
end