# -*- encoding: utf-8 -*-
require 'test/unit'
require './ParseResult'
require './StringParser'

class ScannerTest < Test::Unit::TestCase
  def testEmptyString
    # arrange
    sc = Scanner.new(nil, nil)

    # act
    sc.parse('')

    # assert
    assert_equal([false, false], sc.popToken)
  end

  def testSimpleTokenize
    # arrange
    sc = Scanner.new(nil, nil)

    # act
    sc.parse('A B')

    # assert
    assert_equal([:IDENT, 'A'], sc.popToken)
    assert_equal([:IDENT, 'B'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testKeywords
    # arrange
    sc = Scanner.new(['struct', 'enum'], nil)

    # act
    sc.parse('struct enum')

    # assert
    assert_equal(['struct', 'struct'], sc.popToken)
    assert_equal(['enum', 'enum'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testSymbols
    # arrange
    sc = Scanner.new(nil, [','])

    # act
    sc.parse(',')

    # assert
    assert_equal([',', ','], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testContinuesSymbol
    # arrange
    sc = Scanner.new(nil, [','])

    # act
    sc.parse('A,B')

    # assert
    assert_equal([:IDENT, 'A'], sc.popToken)
    assert_equal([',', ','], sc.popToken)
    assert_equal([:IDENT, 'B'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testLineComment
    # arrange
    sc = Scanner.new(nil, nil)

    # act
    sc.parse(<<-'EOS')
      A//comment
      B
    EOS

    # assert
    assert_equal([:IDENT, 'A'], sc.popToken)
    assert_equal([:IDENT, 'B'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testMultiLineComment
    # arrange
    sc = Scanner.new(nil, nil)

    # act
    sc.parse(<<-'EOS')
      A/*comment
      B//still in comment
      */C
    EOS

    # assert
    assert_equal([:IDENT, 'A'], sc.popToken)
    assert_equal([:IDENT, 'C'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end
end