require_relative 'grammar_mixin'

class GrammarClassifier
  include GrammarMixin

  def initialize(grammar)
    @raw_rules = grammar.P
    @rules =grammar.rules
  end

  def classify
    info = Array.new
    info.push({class: 0, name: 'unrestricted grammar'})
    info.push({class: 1, name: 'noncontracting grammar'}) if noncontracting?
    info.push({class: 1, name: 'context-sensitive grammar'}) if context_sensitive?
    info.push({class: 2, name: 'context-free grammar'}) if context_free?
    info.push({class: 3, name: 'left-regular grammar'}) if left_regular?
    info.push({class: 3, name: 'right-regular grammar'}) if right_regular?
    info
  end

  def noncontracting?
    @rules.all? do |left_chain, right_rules|
      left_chain.length <= right_rules.min_by(&:length).length
    end
  end

  def context_sensitive?
    @rules.all? { |left_chain, _| !N.match(left_chain).nil? }
  end

  def context_free?
    @rules.all? { |left_chain, _| !/^#{N}$/.match(left_chain).nil? }
  end

  def left_regular?
    @raw_rules.all? { |line| !LEFT_REGULAR_RULE.match(line).nil? }
  end

  def right_regular?
    @raw_rules.all? { |line| !RIGHT_REGULAR_RULE.match(line).nil? }
  end

  def regular?
    left_regular? || right_regular?
  end

  private

end