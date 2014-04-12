# -*- encoding: utf-8 -*-
require 'test/unit'
require '../src/Scanner'

class ScannerTest < Test::Unit::TestCase
  include DataDocument

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
    sc.parse('struct structenum enum')

    # assert
    assert_equal(['struct', 'struct'], sc.popToken)
    assert_equal([:IDENT, 'structenum'], sc.popToken)
    assert_equal(['enum', 'enum'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testSymbols
    # arrange
    sc = Scanner.new(nil, [',', '{', '}'])

    # act
    sc.parse('{,}')

    # assert
    assert_equal(['{', '{'], sc.popToken)
    assert_equal([',', ','], sc.popToken)
    assert_equal(['}', '}'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testDuplicationKeywordsAndSymbols
    # arrange / act
    sc = Scanner.new(['struct', 'struct'], [',', ','])

    # assert
    assert_equal(['struct'], sc.keywords)
    assert_equal([','], sc.symbols)
  end

  def testNilKeywordsAndSymbols
    # arrange / act
    sc = Scanner.new(['struct', nil, 'enum'], ['{', nil, '}'])

    # assert
    assert_equal(['struct', 'enum'], sc.keywords)
    assert_equal(['{', '}'], sc.symbols)
  end

  def testContinuesSymbol
    # arrange
    sc = Scanner.new(nil, [','])

    # act
    sc.parse('A,B', true)

    # assert
    assert_equal([:IDENT, 'A'], sc.popToken)
    assert_equal([',', ','], sc.popToken)
    assert_equal([:IDENT, 'B'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testContinuesSymbolAndKeyword
    # arrange
    sc = Scanner.new(['struct', 'enum'], [','])

    # act
    sc.parse('struct,enum')

    # assert
    assert_equal(['struct', 'struct'], sc.popToken)
    assert_equal([',', ','], sc.popToken)
    assert_equal(['enum', 'enum'], sc.popToken)
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

  def testNumber
    # arrange
    sc = Scanner.new(nil, [','])
  
    # act
    sc.parse('9,1.5')
  
    # assert
    assert_equal([:NUMBER, 9], sc.popToken)
    assert_equal([',', ','], sc.popToken)
    assert_equal([:NUMBER, 1.5], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end

  def testString
    # arrange
    sc = Scanner.new(nil, [','])
  
    # act
    sc.parse(<<-'EOS')
      A"//"B"/**/"C
    EOS

    assert_equal([:IDENT, 'A'], sc.popToken)
    assert_equal([:STRING, '//'], sc.popToken)
    assert_equal([:IDENT, 'B'], sc.popToken)
    assert_equal([:STRING, '/**/'], sc.popToken)
    assert_equal([:IDENT, 'C'], sc.popToken)
    assert_equal([false, false], sc.popToken)
  end
end