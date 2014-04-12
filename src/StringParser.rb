# -*- encoding: utf-8 -*-

class Scanner
  def initialize(str)
    if str.length < 1 then
      @tokens = []
    else
      @tokens = str.split(/[\s]+/)
    end
  end
  def popToken
    token = @tokens.shift
    case token
    when nil
      return [false, false]
    when 'struct'
      return ['struct', 'struct']
    else
      return [:IDENT, token]
    end
  end
end