# -*- encoding: utf-8 -*-
require 'test/unit'
require '../src/DocParser'

class DocParserTest < Test::Unit::TestCase
  include DataDocument

  def testEnum
    # arrange
    dc = DocParser.new()

    # act
    result = dc.parse(<<-'EOS')
      enum Hoge {
        Data1 = 1,
        Data2 = 2
      }
    EOS

    # assert
    assert_equal(1, result.enums.length)
    assert_equal('Hoge', result.enums[0].name)
    assert_equal(2, result.enums[0].elements.length)
    assert_equal('Data1', result.enums[0].elements[0].name)
    assert_equal(1, result.enums[0].elements[0].value)
    assert_equal('Data2', result.enums[0].elements[1].name)
    assert_equal(2, result.enums[0].elements[1].value)
  end

  def testEnumAttribute
    # arrange
    dc = DocParser.new()

    # act
    result = dc.parse(<<-'EOS')
      [attr_name("HogeName")]
      enum Hoge {
        Data1 = 1
      }
    EOS

    # assert
    assert_equal(1, result.enums[0].attributes.length)
    assert_equal('attr_name', result.enums[0].attributes[0].type)
    assert_equal('HogeName', result.enums[0].attributes[0].value)
  end

  def testEnumElementAttribute
    # arrange
    dc = DocParser.new()

    # act
    result = dc.parse(<<-'EOS')
      enum Hoge {
        [attr_name("Data1Name")]
        Data1 = 1
      }
    EOS

    # assert
    assert_equal(1, result.enums[0].elements[0].attributes.length)
    assert_equal('attr_name', result.enums[0].elements[0].attributes[0].type)
    assert_equal('Data1Name', result.enums[0].elements[0].attributes[0].value)
  end

  def testStruct
    # arrange
    dc = DocParser.new()

    # act
    result = dc.parse(<<-'EOS')
      struct Hoge {
        int32 Data1;
      }
    EOS

    # assert
    assert_equal(1, result.structs[0].elements.length)
    assert_equal('int32', result.structs[0].elements[0].dataType)
    assert_equal('Data1', result.structs[0].elements[0].name)
  end

  def testStructElementDefaultValue
    # arrange
    dc = DocParser.new()

    # act
    result = dc.parse(<<-'EOS')
      struct Hoge {
        int32 Data1 = 1;
        string Data2 = "Huga";
      }
    EOS

    # assert
    assert_equal(2, result.structs[0].elements.length)
    assert_equal('int32', result.structs[0].elements[0].dataType)
    assert_equal('Data1', result.structs[0].elements[0].name)
    assert_equal(1, result.structs[0].elements[0].defaultValue)
    assert_equal('string', result.structs[0].elements[1].dataType)
    assert_equal('Data2', result.structs[0].elements[1].name)
    assert_equal('Huga', result.structs[0].elements[1].defaultValue)
  end

  def testStructElementCount
    # arrange
    dc = DocParser.new()

    # act
    result = dc.parse(<<-'EOS')
      struct Hoge {
        int32 Data1;
        int32 Data2[];
        int32 Data3[2];
      }
    EOS

    # assert
    assert_equal(1, result.structs[0].elements[0].count)
    assert_equal(-1, result.structs[0].elements[1].count)
    assert_equal(2, result.structs[0].elements[2].count)
  end

  def testStructElementCondition
    # arrange
    dc = DocParser.new()

    # act
    result = dc.parse(<<-'EOS')
      struct Hoge {
        int32 Data1(1);
        int32 Data2(..2);
        int32 Data3(3..);
        int32 Data4(4..5);
        int32 Data5(..6, 8..9, 11, 13..);
      }
    EOS

    # assert
    assert_equal(1, result.structs[0].elements[0].conditions.length)
    assert_equal('1..1', result.structs[0].elements[0].conditions[0])
    assert_equal('Min..2', result.structs[0].elements[1].conditions[0])
    assert_equal('3..Max', result.structs[0].elements[2].conditions[0])
    assert_equal('4..5', result.structs[0].elements[3].conditions[0])
    assert_equal(4, result.structs[0].elements[4].conditions.length)
    assert_equal('Min..6', result.structs[0].elements[4].conditions[0])
    assert_equal('8..9', result.structs[0].elements[4].conditions[1])
    assert_equal('11..11', result.structs[0].elements[4].conditions[2])
    assert_equal('13..Max', result.structs[0].elements[4].conditions[3])
  end

  def testUnnamedStruct
    # arrange
    dc = DocParser.new()

    # act
    result = dc.parse(<<-'EOS')
      struct Hoge {
        struct {
          int32 Data1;
        } Data2[2];
      }
    EOS

    # assert
    assert_equal(1, result.structs.length)
    assert_equal('Data2', result.structs[0].elements[0].name)
    assert_equal(2, result.structs[0].elements[0].count)
    assert_equal('unnamed_struct', result.structs[0].elements[0].dataType.name)
    assert_equal('int32', result.structs[0].elements[0].dataType.elements[0].dataType)
    assert_equal('Data1', result.structs[0].elements[0].dataType.elements[0].name)
  end

  def testStructAttribute
    # arrange
    dc = DocParser.new()

    # act
    result = dc.parse(<<-'EOS')
      [attr_name("HogeName")]
      struct Hoge {
        [attr_name("Data1Name")]
        int32 Data1;
      }
    EOS

    # assert
    assert_equal(1, result.structs.length)
    assert_equal(1, result.structs[0].attributes.length)
    assert_equal('attr_name', result.structs[0].attributes[0].type)
    assert_equal('HogeName', result.structs[0].attributes[0].value)
    assert_equal(1, result.structs[0].elements[0].attributes.length)
    assert_equal('attr_name', result.structs[0].elements[0].attributes[0].type)
    assert_equal('Data1Name', result.structs[0].elements[0].attributes[0].value)
  end
end