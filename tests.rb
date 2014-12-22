require 'test/unit'
require './repartija-cmd'

class TestRepartija < Test::Unit::TestCase

  def setup
    @pagos = {miguel: 100, pedro: 30, miguel: 0, julián: 0}
  end

  def repartija_test
    assert_equal {juan: {miguel: 30, julián: 5}, pedro: {miguel: 20}}, calcular(@pagos)
  end   	
end