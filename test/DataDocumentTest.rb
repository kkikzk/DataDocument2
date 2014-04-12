# -*- encoding: utf-8 -*-
require 'test/unit'
require './ParseResult'
require './StringParser'

class ScannerTest < Test::Unit::TestCase
  def testEmptyString
    # act
    sc = Scanner.new('')

    # assert
    assert_equal([false, false], sc.popToken)
  end

  def testSimpleTokenize
    # act
    sc = Scanner.new('A B')

    # assert
    assert_equal([:IDENT, 'A'], sc.popToken)
    assert_equal([:IDENT, 'B'], sc.popToken)
  end
end