require './store.rb'
require './room.rb'

room = Room.new
room.add({
      Bufarra: 40,
      Martin: 378,
      Joni: 110,
      Pedro: 0,
      Cachi: 0,
      Gisela: 172,
      Eze: 0
    })

store = Store.new
store.process(room.data, room.individual_paiment)
