require "date"

class Event
  attr_reader :participants

  def initialize
    @participants ||= {}
  end

  public
  def add(user_name, payment)
    @participants[user_name] ||= payment
  end
  
end
