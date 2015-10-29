class Room
	attr_accessor :data
	attr_reader :individual_payment
	
	def initialize(data = {})
		@data = data
	end

	public
	def add(input)
		@total = input.values.reduce(:+)
    @individual_payment = @total/input.length
    @data = input.inject({}) do |hash, (k, v)|
    	hash.merge( k.to_sym => @individual_payment - v )
  	end
	end

end
