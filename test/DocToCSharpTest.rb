# -*- encoding: utf-8 -*-
require 'test/unit'
require '../src/DocParser'
require '../src/DocToCSharp'

class DocToCSharpTest < Test::Unit::TestCase
  include DataDocument

  def testEnum
    # arrange
    dc = DocParser.new()
    parseResult = dc.parse(<<-'EOS')
      [attr_name("HogeName")]
      enum Hoge {
        [attr_name("Data1Name")]
        Data1 = 1,
        [attr_name("Data2Name")]
        Data2 = 2
      }
    EOS

    # act
    dtc = DocToCSharp.new(parseResult)
    result = dtc.make()

    # assert
    assert_equal('include System;', result[0])
    assert_equal('', result[1])
    assert_equal('namespace DataDocument', result[2])
    assert_equal('{', result[3])
    assert_equal('    /// <summary>HogeName</summary>', result[4])
    assert_equal('    public enum Hoge', result[5])
    assert_equal('    {', result[6])
    assert_equal('        /// <summary>Data1Name</summary>', result[7])
    assert_equal('        Data1 = 1,', result[8])
    assert_equal('        /// <summary>Data2Name</summary>', result[9])
    assert_equal('        Data2 = 2,', result[10])
    assert_equal('    }', result[11])
    assert_equal('', result[12])
    assert_equal('}', result[13])
    assert_equal('', result[14])
  end

  def testStruct
    # arrange
    dc = DocParser.new()
    parseResult = dc.parse(<<-'EOS')
      [attr_name("HogeName")]
      struct Hoge {
        [attr_name("Data1Name")]
        int32 Data1;
        [attr_name("Data2Name")]
        int32 Data2;
      }
    EOS

    # act
    dtc = DocToCSharp.new(parseResult)
    result = dtc.make()

    # assert
    result.each do |r|
      p r
    end
    assert_equal('    /// <summary>HogeName</summary>', result[4])
    assert_equal('    public class Hoge', result[5])
    assert_equal('    {', result[6])
    assert_equal('        /// <summary>Data1Name</summary>', result[7])
    assert_equal('        public Int32 Data1 { set; get; }', result[8])
    assert_equal('        /// <summary>Data2Name</summary>', result[9])
    assert_equal('        public Int32 Data2 { set; get; }', result[10])
  end

  def testStructDataType
    # arrange
    dc = DocParser.new()
    parseResult = dc.parse(<<-'EOS')
      [attr_name("言語設定")]
      enum LanguageType {
        [attr_name("日本語")]
        Japanese = 1,
        [attr_name("英語")]
        English = 2
      }
      [attr_name("Hogeデータ")]
      struct Hoge {
        [attr_name("Data1Name")]
        int64 Data1(1..100, 105) = 1;
        [attr_name("Data2Name")]
        int32 Data2(..2, 100..) = 2;
        [attr_name("Data3Name")]
        int16 Data3[2] = 5;
        [attr_name("Data4Name")]
        int8 Data4;
        [attr_name("Data5Name")]
        LanguageType Data5;
        [attr_name("Data6Name")]
        Huga Data6;
        [attr_name("Data7Name")]
        Huga Data7[2];
        [attr_name("Data8Name")]
        decimal Data8;
        [attr_name("Data9Name")]
        [attr_fixed_length_string("10")]
        string Data9(0..10) = "ABCD";
        [attr_name("Data10Name")]
        string Data10(0..20);
      }
      struct Huga {
        uint64 Data5;
        uint32 Data6;
        uint16 Data7;
        uint8 Data8;
        bool Data9;
        char Data10;
        double Data11;
        float Data12;
      }
    EOS

    # act
    dtc = DocToCSharp.new(parseResult)
    result = dtc.make()

    # assert
    result.each do |r|
      p r
    end
    assert_equal('    /// <summary>HogeName</summary>', result[4])
    assert_equal('    public class Hoge', result[5])
    assert_equal('    {', result[6])
    assert_equal('        /// <summary>Data1Name</summary>', result[7])
    assert_equal('        public Int32 Data1 { set; get; }', result[8])
    assert_equal('        /// <summary>Data2Name</summary>', result[9])
    assert_equal('        public Int32 Data2 { set; get; }', result[10])
  end
end