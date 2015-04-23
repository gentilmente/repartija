#para que se puedan ejecutar los test hay que seguir los pasos de 
#http://www.sinatrarb.com/testing.html porque calcular() 
#está dentro de los helpers en main.rb


require 'test/unit'
require './main.rb'

class TestRepartija < Test::Unit::TestCase

  def setup
    @pagos = { 
      Bufarra: 40, 
      Martin: 600,  
      Joni: 152,  
      Pedro: 0,  
      Cachi: 0, 
      Gisela: 200,
      Eze: 0  
    }
  end

  def test_one
    resultados = {Martin: {Bufarra: 101, Pedro: 141, Cachi: 141, Eze: 76},
      Joni: {Eze:11}, Gisela: {Eze: 56}}

    assert_equal resultados, calcular(@pagos)
  end   	
end