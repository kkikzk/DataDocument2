# -*- encoding: utf-8 -*-

class Scanner
  KEYWORDS = [
    'struct',
    'enum'
  ]

  def initialize(str)
    if str.length < 1 then
      @tokens = []
    else
      @tokens = str.split(/[\s]+/)
    end
  end
  def popToken
    token = @tokens.shift
    if (token == nil)
      [false, false]
    elsif (KEYWORDS.include? token)
      [token, token]
    else
      [:IDENT, token]
    end
  end
end