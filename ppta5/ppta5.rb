require 'json'
require_relative 'grammar'
require_relative 'pushdown_automaton'

# G=(T, N, P, S)
# G=({Q, A, B, C, D}, {a, b, c, d}, P, Q)

grammar_definition = JSON.load File.new("grammar.json")
grammar = Grammar.new(grammar_definition)
pushdown_automaton = PushdownAutomaton.new(grammar)

accepted = pushdown_automaton.recognize('acab')
puts "Is string accepted? : #{accepted}"
puts "rules applied: #{pushdown_automaton.rules_applied}"

2.times {puts;}

not_accepted = pushdown_automaton.recognize('acacb')
puts "Is string accepted? : #{not_accepted}"


4.times {puts;}


extended_grammar_definition = JSON.load File.new("extended_grammar.json")
grammar = Grammar.new(extended_grammar_definition)
extended_pushdown_automaton = ExtendedPushdownAutomaton.new(grammar)

accepted = extended_pushdown_automaton.recognize('acab')
puts "Is string accepted? : #{accepted}"
puts "rules applied: #{extended_pushdown_automaton.rules_applied}"

2.times {puts;}

not_accepted = extended_pushdown_automaton.recognize('acacb')
puts "Is string accepted? : #{not_accepted}"