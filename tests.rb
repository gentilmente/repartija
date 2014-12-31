require 'test/unit'
require './repartija-cmd'

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
    assert_equal {
    	Martin: {Bufarra: 101, Pedro: 141, Cachi: 141, Eze: 76},
    	Joni: {Eze: 85}
    	Gisela: {Eze: 56}
    	}, calcular(@pagos)
  end   	
end