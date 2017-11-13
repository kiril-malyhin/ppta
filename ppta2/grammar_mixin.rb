module GrammarMixin
  CHAIN = /[A-Za-z0-9λε#~&]+/
  ARROW = /((->)|→)/
  RULE = /^(?<left>#{CHAIN})#{ARROW}(?<right>#{CHAIN}(\|#{CHAIN})*)$/

  N = /[A-Z]/
  T = /[a-z0-9λε#~&]/
  LEFT_REGULAR_RULE = /^#{N}#{ARROW}(#{N}#{T}|#{T})(\|(#{N}#{T}|#{T}))*$/
  RIGHT_REGULAR_RULE = /^#{N}#{ARROW}(#{T}#{N}|#{T})(\|(#{T}#{N}|#{T}))*$/

  def generate_nonterm(set)
    (('A'..'Z').to_a - set)[0]
  end

  def generate_nonterm_in(set)
    nonterm = generate_nonterm(set)
    set << nonterm
    nonterm
  end
end
