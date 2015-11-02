require './balancer.rb'
require 'test/unit'

class TestRepartija < Test::Unit::TestCase
  
  def setup
    @balancer = Balancer.new
    @payments = { 
      Bufarra: 40, 
      Martin: 378,  
      Joni: 110,  
      Pedro: 0,  
      Cachi: 0, 
      Gisela: 172,
      Eze: 0  
    }

    @result = {:Martin=>{:Bufarra=>60, 
      :Pedro=>100, :Cachi=>100, :Eze=>18}, 
      :Joni=>{:Eze=>10}, :Gisela=>{:Eze=>72}}
  end

  def test_one
    assert_equal(@balancer.process({}), {}, "empty hash must return empty hash:")
  end

  def test_two
    assert_equal(@balancer.process(@payments), @result, "result is different from what is expected:")
  end     


end