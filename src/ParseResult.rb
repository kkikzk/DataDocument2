# -*- encoding: utf-8 -*-
module DataDocument
  class ParseResult
    attr_reader :enums, :structs
    def initialize
      @enums = []
      @structs = []
    end
    def addEnum(enum)
      @enums.push(enum)
    end
    def addStruct(struct)
      @structs.push(struct)
    end
  end

  class StructData
    attr_reader :name, :attributes, :baseType, :elements
    def initialize(name, attributes, baseType, elements)
      @name = name
      @attributes = attributes
      @baseType = baseType
      @elements = elements
    end
  end

  class StructElement
    attr_reader :name, :attributes, :dataType, :conditions, :count, :defaultValue 
    def initialize(name, attributes, dataType, conditions, count, defaultValue)
      @name = name
      @attributes = attributes
      @dataType = dataType
      @conditions = conditions
      @count = count
      @defaultValue = defaultValue
    end
  end

  class EnumData
    attr_reader :name, :attributes, :elements
    def initialize(name, attributes, elements)
      @name = name
      @attributes = attributes
      @elements = elements
    end
  end

  class EnumElement
    attr_reader :name, :attributes, :value
    def initialize(name, attributes, value)
      @name = name
      @attributes = attributes
      @value = value
    end
  end

  class Attribute
    attr_reader :type, :value
    def initialize(type, value)
      @type = type
      @value = value
    end
  end
end