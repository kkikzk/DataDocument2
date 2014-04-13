# -*- encoding: utf-8 -*-
require '../src/DocParser'

module DataDocument
  class DocToCSharp
    NEW_LINE_CHAR = '¥r¥n'
    attr_reader :result

    def initialize(parseResult)
      @p = parseResult
      @result = []
    end

    def push(indentLevel, str)
      if 0 < str.length
        @result.push ('    ' * indentLevel) + str
      else
        @result.push ''
      end
    end

    def make
      @result = []
      makeNamespace
      makeEnum
      makeStruct
      makeValidator
      makeIndexer
      return @result
    end

    def makeNamespace
      push 0, 'using System;'
      push 0, 'using System.Collections.Generic;'
      push 0, 'using System.Diagnostics;'
      push 0, ''
    end

    def makaSummary(indentLevel, summary)
      push indentLevel, '/// <summary>'
      push indentLevel, '/// ' + summary
      push indentLevel, '/// </summary>'
    end

    def makeNameAttr(indentLevel, attributes)
      attributes.each do |a|
        if a.type == 'attr_name'
          makaSummary indentLevel, a.value
          break
        end
      end
    end

    def makeValidator
      push 0, 'namespace DataDocument'
      push 0, '{'
      push 1, '    internal class RangeValidator<T>'
      push 1, '    {'
  		push 1, '        private IEnumable<Tuple<T, T>> _ragnes;'
  		push 1, '        public Validator(IEnumable<Tuple<T, T>> ranges)'
  		push 1, '        {'
  		push 1, '            _ragnes = ranges'
  		push 1, '        }'
      push 1, '        public Validate(Func<T> valueGetter)'
  		push 1, '        {'
      push 1, '            value = valueGetter();'
  		push 1, '            foreach (var range in _ranges)'
  		push 1, '            {'
  		push 1, '                if (range.Item1 <= value && value <= range.Item2)'
  		push 1, '                {'
  		push 1, '                    return;'
  		push 1, '                }'
  		push 1, '            }'
  		push 1, '            throw new ArgumentException();'
  		push 1, '        }'
      push 1, '    }'
      push 0, '}'
      push 0, ''
    end

    def makeIndexer
      push 0, 'namespace DataDocument'
      push 0, '{'
  		push 0, '    internal class Indexer<T>'
  		push 0, '    {'
  		push 0, '        private T[] _array;'
      push 0, '        public RangeValidator<T> Validator { set; get; }'
  		push 0, '        public T this[int i]'
  		push 0, '        {'
  		push 0, '            set'
      push 0, '            {'
      push 0, '                if (Validator != null) Validator.Validate(value)'
      push 0, '                _array[i] = value;'
      push 0, '            }'
  		push 0, '            get { return _array[i]; }'
  		push 0, '        }'
  		push 0, '        public Indexer(int count)'
  		push 0, '        {'
  		push 0, '            _array = new T[count];'
  		push 0, '        }'
  		push 0, '    }'
      push 0, '}'
      push 0, ''
    end

    def makeEnum
      @p.enums.each do |e|
        push 0, 'namespace DataDocument'
        push 0, '{'
        makeNameAttr 1, e.attributes
        push 1, 'public enum ' + e.name
        push 1, '{'
        e.elements.each do |element|
          makeNameAttr 2, element.attributes
          push 2, element.name + ' = ' + element.value.to_s + ','
        end
        push 1, '}'
        push 0, '}'
        push 0, ''
      end
    end

    def toCSharpeType(dataType)
      case dataType
      when 'int64'
        'Int64'
      when 'int32'
        'Int32'
      when 'int16'
        'Int16'
      when 'int8'
        'SByte'
      when 'uint64'
        'UInt64'
      when 'uint32'
        'UInt32'
      when 'uint16'
        'UInt16'
      when 'uint8'
        'Byte'
      when 'bool'
        'bool'
      when 'string'
        'string'
      when 'decimal'
        'Decimal'
      when 'float'
        'Single'
      when 'double'
        'Double'
      when 'char'
        'Char'
      else
        dataType
      end
    end

    def toDataSize(dataType)
      case dataType
      when 'decimal'
        16
      when 'int64', 'uint64', 'double'
        8
      when 'int32', 'uint32', 'float'
        4
      when 'int16', 'uint16', 'char'
        2
      when 'int8', 'uint8', 'bool'
        1
      else
        if isEnum(dataType)
          4
        else
          raise 'Undefined type found. name="' + dataType.to_s + '"'
        end
      end
    end

    def getRange(condition, dataType)
      range = condition.split('..')
      if range[0] == 'Min'
        range[0] = toCSharpeType(dataType) + '.MinValue'
      elsif range[0] == 'Max'
        range[0] = toCSharpeType(dataType) + '.MaxValue'
      end
      if range[1] == 'Min'
        range[1] = toCSharpeType(dataType) + '.MinValue'
      elsif range[1] == 'Max'
        range[1] = toCSharpeType(dataType) + '.MaxValue'
      end
      return range
    end

    def toVariableName(name)
      '_' + name
    end

    def isStruct(dataType)
      @p.structs.each do |s|
        if dataType == s.name
          return true
        end
      end
      return false
    end

    def isEnum(dataType)
      @p.enums.each do |e|
        if dataType == e.name
          return true
        end
      end
      return false
    end

    def makeVariables(indentLevel, struct)
      struct.elements.each do |e|
        if e.count == 1
          push indentLevel, 'private ' + toCSharpeType(e.dataType) +
            ' ' + toVariableName(e.name) + (isStruct(e.dataType) ? ' = new ' + e.dataType + '()' : '') + ';'
        else
          push indentLevel, 'private ' + toCSharpeType(e.dataType) +
            '[] ' + toVariableName(e.name) + ' = new ' + toCSharpeType(e.dataType) + '[' + e.count.to_s + '];'
        end
      end
    end

    def makeAccessor(indentLevel, struct)
      struct.elements.each do |e|
        if e.conditions == nil && e.count == 1 then
          makeNameAttr indentLevel, e.attributes
          push indentLevel, 'public ' + toCSharpeType(e.dataType) + ' ' + e.name
          push indentLevel, '{'
          push indentLevel, '    [DebuggerStepThrough]'
          push indentLevel, '    set { ' + toVariableName(e.name) + ' = value; }'
          push indentLevel, '    [DebuggerStepThrough]'
          push indentLevel, '    get { return ' + toVariableName(e.name) + '; }'
          push indentLevel, '}'
        elsif e.count != 1 then
          makeNameAttr indentLevel, e.attributes
          push indentLevel, 'public ' + toCSharpeType(e.dataType) + '[] ' + e.name
          push indentLevel, '{'
          push indentLevel, '    [DebuggerStepThrough]'
          push indentLevel, '    set { ' + toVariableName(e.name) + ' = value; }'
          push indentLevel, '    [DebuggerStepThrough]'
          push indentLevel, '    get { return ' + toVariableName(e.name) + '; }'
          push indentLevel, '}'
        else
          makeNameAttr 2, e.attributes
          validationType = ((e.dataType == 'string') ? 'int' : toCSharpeType(e.dataType))
          validationDataGetter = ((e.dataType == 'string') ? '() => value.Length' : '() => value')
          push indentLevel, 'public ' + toCSharpeType(e.dataType) + ' ' + e.name
          push indentLevel, '{'
          push indentLevel, '    [DebuggerStepThrough]'
          push indentLevel, '    set'
          push indentLevel, '    {'
          push indentLevel, '        Tuple<' + validationType + ', ' + validationType + '>[] conditions = new Tuple<' + validationType + ', ' + validationType + '>[] {'
          e.conditions.each do |c|
            range = getRange(c, e.dataType)
            push indentLevel, '            new Tuple<' + validationType + ', ' + validationType + '>(' + range[0] + ', ' + range[1] + '),' 
          end
          push indentLevel, '        }'
          push indentLevel, '        new DataDocument::RangeValidator<' + validationType + '>(conditions).Validate(' + validationDataGetter + ')'
          push indentLevel, '        _' + e.name + ' = value;'
          push indentLevel, '    }'
          push indentLevel, '    [DebuggerStepThrough]'
          push indentLevel, '    get { return _' + e.name + '; }'
          push indentLevel, '}'
        end
        push indentLevel, ''
      end
    end

    def makeConstructor(indentLevel, struct)
      makaSummary indentLevel, 'Constructor'
      push indentLevel, 'public ' + struct.name + '()'
      push indentLevel, '{'
      struct.elements.each do |e|
        if e.defaultValue != nil
          push indentLevel, '    ' + e.name +
            ' = ' + ((e.dataType == 'string') ? '"' + e.defaultValue.to_s + '"' : e.defaultValue.to_s) + ';'
        elsif 1 < e.count && isStruct(e.dataType)
          push indentLevel, '    for (int i = 0; i < ' + e.count.to_s + '; ++i)'
          push indentLevel, '    {'
          push indentLevel, '        ' + e.name + '[i] = new ' + e.dataType + '();'
          push indentLevel, '    }'
        end
      end
      push indentLevel, '}'
    end

    def makeWriterMethod(indentLevel, struct)
      makaSummary indentLevel, 'to convert data to stream'
      push indentLevel, 'public void Write(Stream s)'
      push indentLevel, '{'
      struct.elements.each do |e|
        if e.count != 1
          push indentLevel, '    s.Write(BitConverter.GetBytes(' + e.count.to_s + ', 0, 4))'
          push indentLevel, '    for (int i = 0; i < ' + e.count.to_s + '; ++i)'
          push indentLevel, '    {'
          if isStruct(e.dataType)
            push indentLevel, '        ' + toVariableName(e.name) + '[i].Write(s);'
          else
            push indentLevel, '        s.Write(BitConverter.GetBytes(' + toVariableName(e.name) + '[i]), 0, ' + toDataSize(e.dataType).to_s + ');'
          end
          push indentLevel, '    }'
        else
          if isStruct(e.dataType)
            push indentLevel, '    ' + e.name + '.Write(s);'
          elsif e.dataType == 'uint8'
            push indentLevel, '    s.WriteByte(' + e.name + ');'
          elsif e.dataType == 'int8'
            push indentLevel, '    s.WriteByte((Byte)' + e.name + ')'
          elsif e.dataType == 'decimal'
            push indentLevel, '    foreach (int i in decimal.GetBits(' + e.name + '))'
            push indentLevel, '    {'
            push indentLevel, '        s.Write(BitConverter.GetBytes(i), 0, sizeof(int));'
            push indentLevel, '    }'
          elsif e.dataType == 'string'
            push indentLevel, '    s.Write(BitConverter.GetBytes(' + e.name + '.Length), 0, sizeof(int));'
            push indentLevel, '    foreach (char c in ' + e.name + '.ToCharArray())'
            push indentLevel, '    {'
            push indentLevel, '        s.Write(BitConverter.GetBytes(c), 0, sizeof(char));'
            push indentLevel, '    }'
          elsif isEnum(e.dataType)
            push indentLevel, '    s.Write(BitConverter.GetBytes((int)' + e.name + '), 0, ' + toDataSize(e.dataType).to_s + ');'
          else
            push indentLevel, '    s.Write(BitConverter.GetBytes(' + e.name + '), 0, ' + toDataSize(e.dataType).to_s + ');'
          end
        end
      end
      push indentLevel, '}'
    end

    def makeReaderMethod(indentLevel, struct)
      makaSummary indentLevel, 'to convert stream to data'
      push indentLevel, 'public void Read(Stream s)'
      push indentLevel, '{'
      push indentLevel, '}'
    end

    def makeStruct
      @p.structs.each do |s|
        push 0, 'namespace DataDocument'
        push 0, '{'
        makeNameAttr 1, s.attributes
        push 1, 'public class ' + s.name
        push 1, '{'
        makeVariables 2, s
        push 2, ''
        makeAccessor 2, s
        makeConstructor 2, s
        push 2, ''
        makeWriterMethod 2, s
        push 2, ''
        makeReaderMethod 2, s
        push 1, '}'
        push 0, '}'
        push 0, ''
      end
    end
  end
end