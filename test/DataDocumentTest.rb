# -*- encoding: utf-8 -*-
require 'test/unit'
require './ParseResult'
require './StringParser'
require './DocParser'

class ScannerTest < Test::Unit::TestCase
  include DataDocument
  include StringParser

  def testEmptyString
    # act
    sc = Scanner.new('')

    # assert
    assesrt_equal([false, false], sc.popToken)
  end
end