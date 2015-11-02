require './balancer.rb'
require './event.rb'

event = Event.new
balancer = Balancer.new

event.add("Bufarra", 40)
event.add("Martin", 378)
event.add("Joni", 110)
event.add("Pedro", 0)
event.add("Cachi", 0)
event.add("Gisela", 172)
event.add("Eze", 0)

balancer.process(event.participants)