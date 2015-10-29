class Room
	attr_accessor :data
	attr_reader :individual_paiment
	
	def initialize(data = {})
		@data = data
	end

	public
	def add(input)
		@total = input.values.reduce(:+)
    @individual_paiment = @total/input.length
    @data = input.inject({}) do |hash, (k, v)|
    	hash.merge( k.to_sym => @individual_paiment - v )
  	end
	end

end
