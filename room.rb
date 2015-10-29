class Room
  attr_accessor :date
  attr_reader :participants

  def initialize(date = DateTime.now)
    @date = date
    @participants ||= {}
  end

  public
  def add(user_name, payment)
    @participants[user_name.to_sym] ||= payment
  end
end
