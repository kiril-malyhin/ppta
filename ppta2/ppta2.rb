require 'json'
require_relative 'grammar'
require_relative 'finite_state_mashine'

# G=(T, N, P, S)
# G=({X, Y, Z, W, V}, {0, 1, ~, #, &}, P, X)
grammar_definition = JSON.load File.new("regular_grammar.json")

grammar = Grammar.new(grammar_definition)

nfa = NFA.new(grammar)
puts "is deterministic? #{nfa.deterministic?}"
nfa.output("nfa")
nfa.console

2.times { puts }

dfa = DFA.new(nfa)
dfa.output("dfa")
dfa.console
