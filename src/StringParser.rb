# -*- encoding: utf-8 -*-

class Scanner
  def initialize(keywords, symbols)
    @keywords = ((keywords == nil) ? [] : keywords)
    @symbols = ((symbols == nil) ? [] : symbols)
  end

  def parse(str)
    str = separateSymbols(Scanner.removeLineComment(Scanner.removeMultiLineComment(str.strip))).strip
    if str.length < 1 then
      @tokens = []
    else
      @tokens = str.split(/[\s]+/)
    end
  end

  def self.removeMultiLineComment(str)
    str.gsub(/\/\*.*\*\//m, ' ')
  end

  def self.removeLineComment(str)
    str.gsub(/\/\/.*$/, '')
  end

  def separateSymbols(str)
    clonedString = str.clone
    @symbols.each{|value| clonedString.gsub!(value, ' ' + value + ' ')}
    return clonedString
  end

  def popToken
    token = @tokens.shift
    if (token == nil)
      [false, false]
    elsif isReserved?(token)
      [token, token]
    else
      [:IDENT, token]
    end
  end

  def isReserved?(token)
    @keywords.include?(token) || @symbols.include?(token)
  end
end