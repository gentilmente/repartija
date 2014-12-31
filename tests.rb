require 'test/unit'
require './main.rb'

class TestRepartija < Test::Unit::TestCase

  def setup
    @pagos = { 
      Bufarra: 40, 
      Martin: 600,  
      Joni: 150,  
      Pedro: 0,  
      Cachi: 0, 
      Gisela: 200,
      Eze: 0  
    }
  end

  def repartija_test
    resultados = {Martin: {Bufarra: 101, Pedro: 141, Cachi: 141, Eze: 76},
      Joni: {Eze: 85}, Gisela: {Eze: 56}}
    assert_equal resultados, calcular(@pagos)
  end   	
end