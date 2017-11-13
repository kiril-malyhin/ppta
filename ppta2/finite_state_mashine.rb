require_relative 'grammar_mixin'
require_relative 'graph_drawer'

class FSM
  include GrammarMixin
  extend Forwardable
  # Q - states set
  # T - input symbols set
  # F - transition func QxT
  # H - initial states set
  # Z - finish states set

  def_delegators :@graph_drawer, :output
  attr_accessor :rules, :Q, :T, :F, :H, :Z

  def initialize
    @Q = []
    @T = []
    @F = Hash.new { |hash, key| hash[key] = Hash.new }
    @H = []
    @Z = []

    @graph_drawer = GraphDrawer.new(self)
  end

  def console
    puts "Q: #{@Q}"
    puts "T: #{@T}"
    puts "F: #{@F}"
    puts "H: #{@H}"
    puts "Z: #{@Z}"
  end

end

class NFA < FSM

  def initialize(grammar)
    super()
    @grammar = grammar
    @rules = @grammar.parse_rules
    raise StandardError, 'Grammar is not right-regular' unless @grammar.right_regular?

    complete_grammar_with_new_N
    form_state_sets
    rules_to_transition_function
    form_final_states
    process_init_grammar_sym
  end

  def deterministic?
    !has_void_chain_transitions? && !has_state_transitions_with_one_sym?
  end

  def console
    puts "NFA"
    super
  end

  private

  def complete_grammar_with_new_N
    @rules.each do |nonterm, right_rules|
      term_rules = right_rules.select { |r| r =~ /^#{T}$/ }
      nonterm_rules = right_rules - term_rules
      term_rules.each do |term_rule|
        unless nonterm_rules.find { |rules| rules =~ /^#{term_rule}#{N}$/ }
          right_rules.push("#{term_rule}#{new_N}")
        end
      end
      # remove term rules
      @rules[nonterm] -= term_rules
    end
  end

  def new_N
    @new_N ||= generate_nonterm(@grammar.N)
  end

  def rules_to_transition_function
    @rules.each do |left_nonterm, right_rules|
      right_rules.each do |right_rule|
        right_term = right_rule[0]
        right_nonterm = right_rule[1]
        @F[left_nonterm][right_term] ||= []
        @F[left_nonterm][right_term] << right_nonterm
      end
    end
  end

  def form_state_sets
    @H.push(*@grammar.S)
    @Q.push(*(@grammar.N + [new_N]))
    @T.push(*@grammar.T)
  end

  def form_final_states
    @Z.push(new_N) unless @new_N.nil?
  end

  def process_init_grammar_sym
    @Z.push(@grammar.S) if @grammar.rules[@grammar.S].include?('ε')
  end

  def has_void_chain_transitions?
    @rules.keys.all? { |left_nonterm| !@rules[left_nonterm].include?('ε') }
  end

  def has_state_transitions_with_one_sym?
    @rules.keys.any? do |left_nonterm|
      right_terms = @rules[left_nonterm].map { |rule| rule[0] }
      right_terms.uniq.length != right_terms.length
    end
  end

end


class DFA < FSM

  attr_accessor :states_map

  def initialize(nfa)
    super()

    @nfa = nfa

    @Q = Marshal.load(Marshal.dump(@nfa.Q))
    @T = Marshal.load(Marshal.dump(@nfa.T))
    @T.push('ε')
    @H = Marshal.load(Marshal.dump(@nfa.H))
    @states_map = {}
    # @iter = 0
    extend_states(@H)

    build_transition_functions(@H)
    form_final_states
    replace_state_sets_with_nonterms_and_remove_blank_rules
  end

  def console
    puts "DFA"
    super
    puts "states map: #{@states_map}"
  end

  private

  def extend_states(transition_set)
    if @states_map[transition_set].nil? && transition_set.length > 1
      @states_map[transition_set] = generate_nonterm_in(@Q)
    end
  end

  def build_transition_functions(col_set)
    @T.each do |term|
      transition_set = []
      col_set.each do |state|
        transition_set.push(*@nfa.F[state][term])
      end

      transition_set.uniq!
      col_nonterm = col_set.length > 1 ? @states_map[col_set] : col_set[0]

      return unless @F[col_nonterm][term].nil?

      @F[col_nonterm][term] = transition_set
      extend_states(transition_set)

      # puts("ITER: #{@iter}")
      # puts(@F)
      # puts(@states_map)
      # @iter += 1
      build_transition_functions(transition_set) unless transition_set.empty?
    end
  end

  def form_final_states
    new_fin_states = @states_map.select do |state_set, _|
      (state_set - @nfa.Z).length != state_set.length
    end.values
    @Z.push(*new_fin_states)
    @Z.push(*@nfa.Z)
  end

  def replace_state_sets_with_nonterms_and_remove_blank_rules
    @F.keys.each do |col_nonterm|
      @F[col_nonterm].keys.each do |term|
        if @F[col_nonterm][term].length > 1
          transition_set = @F[col_nonterm][term]
          @F[col_nonterm][term] = @states_map[transition_set]
        elsif @F[col_nonterm][term].empty?
          @F[col_nonterm].delete(term)
        end
      end
    end
  end
end