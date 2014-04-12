# -*- encoding: utf-8 -*-
require 'test/unit'
require './ParseResult'
require './StringParser'

class ScannerTest < Test::Unit::TestCase
  def testEmptyString
    # arrange
    sc = Scanner.new('')

    # act / assert
    assert_equal([false, false], sc.popToken)
  end

  def testSimpleTokenize
    # arrange
    sc = Scanner.new('A B')

    # act / assert
    assert_equal([:IDENT, 'A'], sc.popToken)
    assert_equal([:IDENT, 'B'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testKeywords
    # arrange
    sc = Scanner.new('struct enum')

    # act / assert
    assert_equal(['struct', 'struct'], sc.popToken)
    assert_equal(['enum', 'enum'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testSymbols
    # arrange
    sc = Scanner.new(',')

    # act / assert
    assert_equal([',', ','], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testLineComment
    # arrange
    sc = Scanner.new(<<-'EOS')
      A//Comment
      B
    EOS

    # act / assert
    assert_equal([:IDENT, 'A'], sc.popToken)
    assert_equal([:IDENT, 'B'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end
end