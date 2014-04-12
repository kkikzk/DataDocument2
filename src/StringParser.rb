# -*- encoding: utf-8 -*-

class Scanner
  KEYWORDS = [
    'struct',
    'enum'
  ]
  SYMBOLS = [
    ','
  ]

  def initialize(str)
    str = Scanner.separateSymbols(Scanner.removeLineComment(Scanner.removeMultiLineComment(str.strip))).strip
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

  def self.separateSymbols(str)
    clonedString = str.clone
    SYMBOLS.each{|value| clonedString.gsub!(value, ' ' + value + ' ')}
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
    KEYWORDS.include?(token) || SYMBOLS.include?(token)
  end
end