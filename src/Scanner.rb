# -*- encoding: utf-8 -*-
module DataDocument
  class Scanner
    attr_reader :keywords, :symbols, :tokens, :str

    def initialize(keywords, symbols)
      @keywords = ((keywords == nil) ? [] : keywords.uniq.compact)
      @symbols = ((symbols == nil) ? [] : symbols.uniq.compact)
    end

    def parse(str, debug = false)
      @str = str
      tokenize(debug)
    end

    def popToken
      token = @tokens.shift
      case token
      when nil
        [false, false]
      when /^[\d]+[\.]?[\d]*\z/
        token.include?('.') ? [:NUMBER, token.to_f] : [:NUMBER, token.to_i]
      when /^\"(.*)\"\z/m
        [:STRING, $1]
      else
        isReserved?(token) ? [token, token] : [:IDENT, token]
      end
    end

    private

    class StringIterator
      attr_reader :index

      def initialize(str)
        @str = str
        @index = 0
        @mark_pos = -1
      end

      def markSet
        @mark_pos = @index
      end

      def is(target_string)
        end_pos = (@index + target_string.length - 1)
        @str[@index..end_pos] == target_string
      end

      def isIn(target_list)
        target_list.each do |target|
          if is(target) then
            return true
          end
        end
        false
      end

      def moveNext
        @index += 1
      end

      def moveToTheEndOfTheLine
        @index += (@str[@index..-1] =~ /$/)
      end

      def moveTo(target)
        esceped_target = Regexp.escape(target)
        @index += (@str[@index..-1] =~ /#{esceped_target}/m) + target.length
      end

      def [](range)
        @str[range]
      end

      def <(pos)
        @index < pos
      end

      def char
        @str[@index]
      end

      def isMarked
        @mark_pos != -1
      end

      def markToLastPos
        result = @str[@mark_pos..(@index - 1)]
        @mark_pos = -1
        return result
      end
    end

    def tokenize(debug)
      @tokens = []
      current_pos = StringIterator.new(@str)

      while current_pos < @str.length do
        if current_pos.char =~ /[\s]/
          if current_pos.isMarked then
            @tokens.push current_pos.markToLastPos
          end
          current_pos.moveNext
          next
        elsif current_pos.is('//') then
          if current_pos.isMarked then
            @tokens.push current_pos.markToLastPos
          end
          current_pos.moveToTheEndOfTheLine
          next
        elsif current_pos.is('/*') then
          if current_pos.isMarked then
            @tokens.push current_pos.markToLastPos
          end
          current_pos.moveTo('*/')
          next
        elsif current_pos.is('"') then
          if current_pos.isMarked then
            @tokens.push current_pos.markToLastPos
          end
          current_pos.markSet
          current_pos.moveNext
          current_pos.moveTo('"')
          p current_pos.index
          @tokens.push current_pos.markToLastPos
          next
        elsif current_pos.isIn(@symbols) then
          @symbols.each do |symbol|
            if current_pos.is(symbol) then
              if current_pos.isMarked then
                @tokens.push current_pos.markToLastPos
              end
              @tokens.push current_pos[current_pos.index..(current_pos.index + symbol.length - 1)]
              for i in 1..(symbol.length - 1) do
                current_pos.moveNext
              end
              break
            end
          end 
        elsif !current_pos.isMarked then
          current_pos.markSet
        end
        current_pos.moveNext
      end

      if current_pos.isMarked then
        @tokens.push current_pos.markToLastPos
      end
    end

    def isReserved?(token)
      @keywords.include?(token) || @symbols.include?(token)
    end
  end
end