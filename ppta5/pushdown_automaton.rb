require_relative 'grammar_mixin'

class AbstractPushdownAutomaton
  include GrammarMixin
  # M = (Q, T, N, F, q0, N0, Z)

  attr_accessor :Q, :q0, :Z, :N, :T, :N0, :F

  def initialize(grammar)
    @grammar = grammar
    grammar_check
  end

  protected

  def grammar_check
    raise StandardError, 'grammar is not a context free one' unless @grammar.context_free?
  end

  def input_char
    @str[@head]
  end

  def rules_for nonterm
    @grammar.rules[nonterm]
  end

  def configuration
    [string_remainder, @stack.dup]
  end

  def remember_config
    @configurations.push(configuration)
  end

end

class PushdownAutomaton < AbstractPushdownAutomaton

  def initialize(grammar)
    super(grammar)
  end

  def load_init_configuration(str)
    @str = str
    @cur_stack_id = 0
    @head = 0
    @stack = []
    @rules_applied = []
    @configurations = []

    put_rule_on_top(@grammar.S)
  end

  def recognize(str)
    load_init_configuration(str)

    begin
      while true
        if string_remainder.empty? && @stack.empty?
          return true
        else
          recognition_step
        end
      end
    rescue => e
      puts e
      puts "rules applied: #{rules_applied}"
      return false
    end
  end

  def rules_applied
    @rules_applied.map { |rule| {rule[:left] => rule[:right] } }
  end

  private

  def nonterm_on_top?
    /^#{GrammarMixin::N}$/ === @stack.last[:sym]
  end

  def term_on_top?
    /^#{GrammarMixin::T}$/ === @stack.last[:sym]
  end

  def rule_term_chain(rule)
    GrammarMixin::T.match(rule).to_a.first
  end

  def save_applied_rule(rule)
    @rules_applied.push(id: @stack.last[:id], left: @stack.last[:sym], right: rule)
  end

  def string_remainder
    @str[@head..-1]
  end

  def load_prev_config
    @head = @str.rindex(@configurations.last[0])
    @stack = @configurations.last[1]
    @configurations.pop
  end

  def sorted_possible_rules(rules)
    str_remainder = string_remainder
    rules_with_nonterms = rules.select { |rule| /^#{GrammarMixin::T}+#{GrammarMixin::N}+/ === rule }
    rules_with_nonterms.select! { |rule| str_remainder.start_with? rule_term_chain(rule) }
    rules_with_nonterms.sort_by!(&:length).reverse!
  end

  def put_rule_on_top(rule)
    rule.chars.reverse_each do |sym|
      @stack.push(id: @cur_stack_id, sym: sym)
      @cur_stack_id += 1
    end
  end

  def select_rule
    str_remainder = string_remainder
    rules = rules_for @stack.last[:sym]

    if (!@rules_applied.last.nil?) && (@rules_applied.last[:id] == @stack.last[:id])
      selected = chose_another_rule
    else
      selected = rules.find { |rule| rule == str_remainder }
      selected = 'ε' if str_remainder.empty? && rules.include?('ε')
      selected = sorted_possible_rules(rules)[0] if selected.nil?
    end
    selected
  end

  def replace_nonterm_with_rule
    selected_rule = select_rule

    if selected_rule.nil?
      load_prev_config
    else
      save_applied_rule(selected_rule)
      remember_config
      @stack.pop
      put_rule_on_top(selected_rule) if selected_rule != 'ε'
    end
  end

  def chose_another_rule
    unsuitable_rule = @rules_applied.pop
    possible_rules = sorted_possible_rules(rules_for(@stack.last[:sym]))
    ind = possible_rules.index(unsuitable_rule[:right]) + 1
    raise StandardError, 'all rules are unsuitable' if ind >= possible_rules.length

    possible_rules[ind]
  end

  def process_term_on_top
    if input_char == @stack.last[:sym]
      @stack.pop
      @head += 1
    else
      load_prev_config
      chose_another_rule
    end
  end

  def recognition_step
    print_configuration
    if nonterm_on_top?
      replace_nonterm_with_rule
    elsif term_on_top?
      process_term_on_top
    end
  end

  def print_configuration
    config = configuration
    stack = @stack.map { |el| el[:sym] }
    puts "remainder: #{config[0].ljust(30)} st: #{stack}"
  end

end


class ExtendedPushdownAutomaton < AbstractPushdownAutomaton

  def initialize(grammar)
    super(grammar)
  end

  def recognize(str)
    load_init_configuration(str)

    begin
      while true
        if str_is_over? && stack_contains_axiom_only?
          return true
        else
          recognition_step
        end
      end
    rescue => e
      puts e
      puts "rules applied: #{rules_applied}"
      return false
    end
  end

  def rules_applied
    @rules_applied.map { |rule| {rule[:nonterm] => rule[:rule] } }
  end

  private

  def str_is_over?
    @head <= -1
  end

  def string_remainder
    @str[0...@head]
  end

  def load_prev_config
    @head = @str.index(@configurations.last[0])
    @stack = @configurations.last[1]
    @configurations.pop
  end

  def stack_contains_axiom_only?
    (@stack.length == 1) && @stack.first == @grammar.S
  end

  def load_init_configuration(str)
    @str = str
    @stack = []
    @rules_applied = []
    @configurations = []
    @head = str.length - 1
    @applied_alternatives = []
  end

  def shift
    @stack.push(input_char)
    @head -= 1
    raise StandardError, "string is over, can't do shift" if @head < -1
  end

  def stack_as_str
    @stack.reverse.join
  end

  def rule_alternatives
    stack_str = stack_as_str
    alternatives = []
    (1..stack_str.length).reverse_each do |i|
      stack_substr = stack_str[0...i]
      suitable_rules = @grammar.rules.select {|left_nonterm, rules| rules.include? stack_substr }
      alternatives.push(*suitable_rules.map{|left_nonterm, rules| {nonterm: left_nonterm, rule: stack_substr } })
    end
    alternatives.uniq{ |a| a[:nonterm] }
  end

  def next_alternative(alternatives)
    ind = alternatives.index(@applied_alternatives.pop) + 1
    raise StandardError, 'there is no alternatives more' if ind >= alternatives.length
    alternatives[ind]
  end

  def reduce
    return false if @stack.empty?

    alternatives = rule_alternatives

    if str_is_over? && alternatives.empty?
      load_prev_config
      alternatives = rule_alternatives
      selected_alternative = next_alternative(alternatives)
    end

    return false if alternatives.empty?

    selected_alternative ||= alternatives[0]

    if alternatives.length > 1
      @applied_alternatives.push(selected_alternative)
      remember_config
    end

    @stack.pop(selected_alternative[:rule].length)
    @stack.push(selected_alternative[:nonterm])

    @rules_applied.push selected_alternative

    true
  end

  def recognition_step
    shift unless reduce
  end

end