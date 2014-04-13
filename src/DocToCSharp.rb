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
      makeStreamHelper
      return @result
    end

    def makeNamespace
      push 0, 'using System;'
      push 0, 'using System.Collections.Generic;'
      push 0, 'using System.Diagnostics;'
      push 0, 'using System.IO;'
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
      push 0, '    internal class RangeValidator<T>'
      push 0, '        where T : IComparable'
      push 0, '    {'
  		push 0, '        private IEnumerable<Tuple<T, T>> _ranges;'
  		push 0, '        public RangeValidator(IEnumerable<Tuple<T, T>> ranges)'
  		push 0, '        {'
  		push 0, '            _ranges = ranges;'
  		push 0, '        }'
      push 0, '        public void Validate(Func<T> valueGetter)'
  		push 0, '        {'
      push 0, '            T value = valueGetter();'
  		push 0, '            foreach (var range in _ranges)'
  		push 0, '            {'
  		push 0, '                if ((range.Item1.CompareTo(value) <= 0) && (value.CompareTo(range.Item2) <= 0))'
  		push 0, '                {'
  		push 0, '                    return;'
  		push 0, '                }'
  		push 0, '            }'
  		push 0, '            throw new ArgumentException();'
  		push 0, '        }'
      push 0, '    }'
      push 0, '}'
      push 0, ''
    end

    def makeIndexer
      push 0, 'namespace DataDocument'
      push 0, '{'
  		push 0, '    public class Indexer<T>'
      push 0, '        where T : IComparable'
  		push 0, '    {'
  		push 0, '        private T[] _array;'
      push 0, '        public DataDocument.RangeValidator<T> Validator { set; get; }'
  		push 0, '        public T this[int i]'
  		push 0, '        {'
  		push 0, '            set'
      push 0, '            {'
      push 0, '                if (Validator != null) Validator.Validate(() => value)'
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
      push 0, 'namespace DataDocument'
      push 0, '{'
  		push 0, '    public class ClassIndexer<T>'
      push 0, '        where T : class'
  		push 0, '    {'
  		push 0, '        private T[] _array;'
  		push 0, '        public T this[int i]'
  		push 0, '        {'
  		push 0, '            set'
      push 0, '            {'
      push 0, '                if (value == null) throw new ArgumentException();'
      push 0, '                _array[i] = value;'
      push 0, '            }'
  		push 0, '            get { return _array[i]; }'
  		push 0, '        }'
  		push 0, '        public ClassIndexer(int count)'
  		push 0, '        {'
  		push 0, '            _array = new T[count];'
  		push 0, '        }'
  		push 0, '    }'
      push 0, '}'
      push 0, ''
    end

    def makeStreamHelper
      push 0, 'namespace DataDocument'
      push 0, '{'
      push 0, '    internal class StreamHelper'
      push 0, '    {'
      push 0, '        public int WriteSize { private set; get; }'
      push 0, '        public List<byte> WriteSumBuffer { private set; get; }'
      push 0, '        public int ReadSize { private set; get; }'
      push 0, '        public List<byte> ReadSumBuffer { private set; get; }'
      push 0, '        internal StreamHelper()'
      push 0, '        {'
      push 0, '            WriteSumBuffer = new List<byte>();'
      push 0, '            ReadSumBuffer = new List<byte>();'
      push 0, '        }'
      push 0, '        void ResetWriteSum() { WriteSumBuffer.Clear(); }'
      push 0, '        void ResetReadSum() { ReadSumBuffer.Clear(); }'
      push 0, '        void Write(Stream s, Int64 data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, Int32 data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, Int16 data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, SByte data) { Write(s, new Byte[] { (Byte)data }); }'
      push 0, '        void Write(Stream s, UInt64 data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, UInt32 data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, UInt16 data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, Byte data) { Write(s, new Byte[] { data }); }'
      push 0, '        void Write(Stream s, Boolean data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, Single data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, Double data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, Char data) { Write(s, BitConverter.GetBytes(data)); }'
      push 0, '        void Write(Stream s, DateTime data) { Write(s, BitConverter.GetBytes(data.ToBinary())); }'
      push 0, '        void Write(Stream s, Decimal data)'
      push 0, '        {'
      push 0, '            int[] bits = Decimal.GetBits(data);'
      push 0, '            foreach (var v in bits)'
      push 0, '            {'
      push 0, '                Write(s, BitConverter.GetBytes(v));'
      push 0, '            }'
      push 0, '            DateTime d;'
      push 0, '        }'
      push 0, '        void Write(Stream s, byte[] data)'
      push 0, '        {'
      push 0, '            WriteSize += data.Length;'
      push 0, '            WriteSumBuffer.AddRange(data);'
      push 0, '            s.Write(data, 0, data.Length);'
      push 0, '        }'
      push 0, '        void Read(Stream s, ref Int64 data) { data = BitConverter.ToInt64(Read(s, sizeof(Int64)), 0); }'
      push 0, '        void Read(Stream s, ref Int32 data) { data = BitConverter.ToInt32(Read(s, sizeof(Int32)), 0); }'
      push 0, '        void Read(Stream s, ref Int16 data) { data =  BitConverter.ToInt16(Read(s, sizeof(Int16)), 0); }'
      push 0, '        void Read(Stream s, ref SByte data) { data = (SByte)Read(s, sizeof(SByte))[0]; }'
      push 0, '        void Read(Stream s, ref UInt64 data) { data = BitConverter.ToUInt64(Read(s, sizeof(UInt64)), 0); }'
      push 0, '        void Read(Stream s, ref UInt32 data) { data = BitConverter.ToUInt32(Read(s, sizeof(UInt32)), 0); }'
      push 0, '        void Read(Stream s, ref UInt16 data) { data = BitConverter.ToUInt16(Read(s, sizeof(UInt16)), 0); }'
      push 0, '        void Read(Stream s, ref Byte data) { data = Read(s, sizeof(Byte))[0]; }'
      push 0, '        void Read(Stream s, ref Boolean data) { data = BitConverter.ToBoolean(Read(s, sizeof(Boolean)), 0); }'
      push 0, '        void Read(Stream s, ref Single data) { data = BitConverter.ToSingle(Read(s, sizeof(Single)), 0); }'
      push 0, '        void Read(Stream s, ref Double data) { data = BitConverter.ToDouble(Read(s, sizeof(Double)), 0); }'
      push 0, '        void Read(Stream s, ref Char data) { data = BitConverter.ToChar(Read(s, sizeof(Char)), 0); }'
      push 0, '        void Read(Stream s, ref DateTime data) { data = DateTime.FromBinary(BitConverter.ToInt64(Read(s, sizeof(Int64)), 0)); }'
      push 0, '        void Read(Stream s, ref Decimal data)'
      push 0, '        {'
      push 0, '            Int32 data1 = BitConverter.ToInt32(Read(s, sizeof(Int32)), 0);'
      push 0, '            Int32 data2 = BitConverter.ToInt32(Read(s, sizeof(Int32)), 0);'
      push 0, '            Int32 data3 = BitConverter.ToInt32(Read(s, sizeof(Int32)), 0);'
      push 0, '            Int32 data4 = BitConverter.ToInt32(Read(s, sizeof(Int32)), 0);'
      push 0, '            bool sign = (data4 & 0x80000000) != 0;'
      push 0, '            Byte scale = (Byte)((data4 >> 16) & (Byte)0x7F);'
      push 0, '            data = new Decimal(data1, data2, data3, sign, scale);'
      push 0, '        }'
      push 0, ''
      push 0, '        byte[] Read(Stream s, int dataSize)'
      push 0, '        {'
      push 0, '            ReadSize += dataSize;'
      push 0, '            byte[] buff = new byte[dataSize];'
      push 0, '            s.Read(buff, 0, buff.Length);'
      push 0, '            ReadSumBuffer.AddRange(buff);'
      push 0, '            return buff;'
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
        'Boolean'
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
          initializeStatement = ''
          if isStruct(e.dataType)
            initializeStatement = ' = new ' + e.dataType + '()'
          elsif e.dataType == 'string'
            initializeStatement = ' = string.Empty'
          end
          push indentLevel, 'private ' + toCSharpeType(e.dataType) + ' ' + toVariableName(e.name) + initializeStatement + ';'
        else
          if isStruct(e.dataType)
            push indentLevel, 'private DataDocument.ClassIndexer<' + toCSharpeType(e.dataType) +
              '> ' + toVariableName(e.name) + ' = new ClassIndexer<' + toCSharpeType(e.dataType) + '>(' + e.count.to_s + ');'
          else
            push indentLevel, 'private DataDocument.Indexer<' + toCSharpeType(e.dataType) +
              '> ' + toVariableName(e.name) + ' = new Indexer<' + toCSharpeType(e.dataType) + '>(' + e.count.to_s + ');'
          end
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
        elsif 1 < e.count then
          makeNameAttr indentLevel, e.attributes
          if isStruct(e.dataType)
            push indentLevel, 'public DataDocument.ClassIndexer<' + toCSharpeType(e.dataType) + '> ' + e.name
          else
            push indentLevel, 'public DataDocument.Indexer<' + toCSharpeType(e.dataType) + '> ' + e.name
          end
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
          push indentLevel, '        };'
          push indentLevel, '        new DataDocument.RangeValidator<' + validationType + '>(conditions).Validate(' + validationDataGetter + ');'
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
        if 1 < e.count && isStruct(e.dataType)
          push indentLevel, '    for (int i = 0; i < ' + e.count.to_s + '; ++i)'
          push indentLevel, '    {'
          push indentLevel, '        ' + e.name + '[i] = new ' + e.dataType + '();'
          push indentLevel, '    }'
        end
        if e.defaultValue != nil
          if 1 < e.count
            push indentLevel, '    for (int i = 0; i < ' + e.count.to_s + '; ++i)'
            push indentLevel, '    {'
            push indentLevel, '        ' + e.name + '[i] = ' +
              ((e.dataType == 'string') ? '"' + e.defaultValue.to_s + '"' : e.defaultValue.to_s) + ';'
            push indentLevel, '    }'
          elsif
            push indentLevel, '    ' + e.name +
              ' = ' + ((e.dataType == 'string') ? '"' + e.defaultValue.to_s + '"' : e.defaultValue.to_s) + ';'
          end
        end
      end
      push indentLevel, '}'
    end

    def makeWriterMethod(indentLevel, struct)
      makaSummary indentLevel, 'to convert data to stream'
      push indentLevel, 'public void Write(Stream s)'
      push indentLevel, '{'
      push indentLevel, '    StreamHelper helper = new StreamHelper();'
      push indentLevel, '    Write(helper, s);'
      push indentLevel, '}'
      push indentLevel, ''
      makaSummary indentLevel, 'to convert data to stream'
      push indentLevel, 'internal void Write(StreamHelper helper, Stream s)'
      push indentLevel, '{'
      struct.elements.each do |e|
        push indentLevel, '    // ' + (hasAttribute(e.attributes, 'attr_name') ? getAttributeValue(e.attributes, 'attr_name') : e.name)
        if e.count != 1
          push indentLevel, '    helper.Write(s, ' + e.count.to_s + ');'
          push indentLevel, '    for (int i = 0; i < ' + e.count.to_s + '; ++i)'
          push indentLevel, '    {'
          if isStruct(e.dataType)
            push indentLevel, '        ' + toVariableName(e.name) + '[i].Write(helper, s);'
          else
            push indentLevel, '        helper.Write(s, ' + e.name + '[i]);'
          end
          push indentLevel, '    }'
        else
          if isStruct(e.dataType)
            push indentLevel, '    ' + e.name + '.Write(helper, s);'
          elsif e.dataType == 'string'
            if hasAttribute(e.attributes, 'attr_fixed_length_string')
              push indentLevel, '    char[] ' + e.name + 'DataArrayTemp = new char[' + getAttributeValue(e.attributes, 'attr_fixed_length_string') + '];'
              push indentLevel, '    for (int i = 0; i < ' + e.name + '.Length; ++i)'
              push indentLevel, '    {'
              push indentLevel, '        ' + e.name + 'DataArrayTemp[i] = ' + e.name + '.ToCharArray()[i];'
              push indentLevel, '    }'
              push indentLevel, '    foreach (char c in ' + e.name + 'DataArrayTemp)'
              push indentLevel, '    {'
              push indentLevel, '        helper.Write(s, c);'
              push indentLevel, '    }'
            else
              push indentLevel, '    helper.Write(s, ' + e.name + '.Length);'
              push indentLevel, '    foreach (char c in ' + e.name + '.ToCharArray())'
              push indentLevel, '    {'
              push indentLevel, '        helper.Write(s, c);'
              push indentLevel, '    }'
            end
          elsif isEnum(e.dataType)
            push indentLevel, '    helper.Write(s, (Int32)' + e.name + ');'
          else
            push indentLevel, '    helper.Write(s, ' + e.name + ');'
          end
        end
      end
      push indentLevel, '}'
    end

    def getAttributeValue(attributes, target)
      attributes.each do |attribute|
        if attribute.type == target
          return attribute.value
        end
      end
      return nil
    end

    def hasAttribute(attributes, target)
      attributes.each do |attribute|
        if attribute.type == target
          return true
        end
      end
      return false
    end

    def makeReaderMethod(indentLevel, struct)
      makaSummary indentLevel, 'to convert stream to data'
      push indentLevel, 'public void Read(Stream s)'
      push indentLevel, '{'
      push indentLevel, '    StreamHelper helper = new StreamHelper();'
      push indentLevel, '    Read(helper, s);'
      push indentLevel, '}'
      push indentLevel, ''
      makaSummary indentLevel, 'to convert stream to data'
      push indentLevel, 'internal void Read(StreamHelper helper, Stream s)'
      push indentLevel, '{'
      struct.elements.each do |e|
        push indentLevel, '    // ' + (hasAttribute(e.attributes, 'attr_name') ? getAttributeValue(e.attributes, 'attr_name') : e.name)
        if e.count != 1
          push indentLevel, '    Int32 ' + e.name + 'LengthTemp = 0;'
          push indentLevel, '    helper.Read(s, ref ' + e.name + 'LengthTemp);'
          push indentLevel, '    for (int i = 0; i < ' + e.name + 'LengthTemp; ++i)'
          push indentLevel, '    {'
          if isStruct(e.dataType)
            push indentLevel, '        ' + toVariableName(e.name) + '[i].Read(helper, s);'
          else
            push indentLevel, '        helper.Read(s, ref ' + e.name + '[i]);'
          end
          push indentLevel, '    }'
        else
          if isStruct(e.dataType)
            push indentLevel, '    ' + e.name + '.Read(helper, s);'
          elsif e.dataType == 'string'
            if hasAttribute(e.attributes, 'attr_fixed_length_string')
              push indentLevel, '    Int32 ' + e.name + 'DataSizeTemp = ' + getAttributeValue(e.attributes, 'attr_fixed_length_string') + ';'
            else
              push indentLevel, '    Int32 ' + e.name + 'DataSizeTemp = 0;'
              push indentLevel, '    helper.Read(s, ref ' + e.name + 'DataSizeTemp);'
            end
            push indentLevel, '    char[] ' + e.name + 'DataArrayTemp = new char[' + e.name + 'DataSizeTemp];'
            push indentLevel, '    for (int i = 0; i < ' + e.name + 'DataArrayTemp.Length; ++i)'
            push indentLevel, '    {'
            push indentLevel, '        helper.Read(s, ref ' + e.name + 'DataArrayTemp[i]);'
            push indentLevel, '    }'
            push indentLevel, '    ' + e.name + ' = new string(' + e.name + 'DataArrayTemp);'
          elsif isEnum(e.dataType)
            push indentLevel, '    Int32 ' + e.name + 'EnumDataTemp = 0;'
            push indentLevel, '    helper.Read(s, ref ' + e.name + 'EnumDataTemp);'
            push indentLevel, '    ' + e.name + ' = (' + e.dataType + ')' + e.name + 'EnumDataTemp;'
          else
            push indentLevel, '    helper.Read(s, ref ' + e.name + ');'
          end
        end
      end
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