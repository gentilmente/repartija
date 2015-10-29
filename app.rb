require './balancer.rb'
require './room.rb'

room = Room.new
balancer = Balancer.new

room.add("Bufarra", 40)
room.add("Martin", 378)
room.add("Joni", 110)
room.add("Pedro", 0)
room.add("Cachi", 0)
room.add("Gisela", 172)
room.add("Eze", 0)


balancer.process(room.participants)

