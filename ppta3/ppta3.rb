require 'json'
require 'csv'
require_relative 'finite_state_machine'

fms_definitions = JSON.load File.new("finite_state_machine.json")

fsm = FSM.new(fms_definitions, 'state_transition_function.csv')

fsm.console
fsm.output("graph")

2.times{ puts; }

fsm.minimize
fsm.console
fsm.output("minimized_graph")
puts "partition: #{fsm.partition}"
puts "group states map: #{fsm.group_states_map}"