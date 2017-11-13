require 'json'

class Grammar
  N = /[A-Z]/
  T = /[a-zλ]/
  RULE = /^(?<left>[a-z]+)->(?<right>[a-zλ]+(\|[a-zλ]+)*)$/i
  LEFT_REGULAR_RULE = /^#{N}->(#{N}#{T}|#{T})(\|(#{N}#{T}|#{T}))*$/
  RIGHT_REGULAR_RULE = /^#{N}->(#{T}#{N}|#{T})(\|(#{T}#{N}|#{T}))*$/

  attr_accessor :rules

  def initialize(lines)
    @lines = lines
    @rules = Hash.new { |hash, key|  hash[key] = Array.new }
    trim
    raise StandardError, "Given grammar contains errors" unless valid?
    parse
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

  def valid?
    @lines.all? { |line| !RULE.match(line).nil? }
  end

  alias unrestricted? valid?

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
    @lines.all? { |line| !LEFT_REGULAR_RULE.match(line).nil? }
  end

  def right_regular?
    @lines.all? { |line| !RIGHT_REGULAR_RULE.match(line).nil? }
  end

  private

  def trim
    @lines.each { |line| line.gsub!(/\s+/,'') }
  end

  def parse
    @lines.each do |line|
      match_data = RULE.match(line)
      left = match_data[:left]
      right = match_data[:right].split('|')
      @rules[left].push(*right)
    end
  end

end

begin
  grammar_definition = JSON.load File.new("grammar.json")

  grammar = Grammar.new(grammar_definition["P"])

  puts "rules:"
  puts grammar.rules
  puts "classification:"
  puts grammar.classify
rescue => e
  puts e
  exit
end