class BaBaParser
  module AST
    TOKENS = Lexer::TOKENS
    def self.parse(lexer)
      @lexer = lexer
      eof = false
      tree = []
      scope = []

      string = false
      waiting_for_endline = false
      until eof
        token = @lexer.consume
        if string && token[0] != TOKENS[:string] && token[0] != TOKENS[:string_mark] && token[0] != TOKENS[:newline]
          raise "BabaParser: Unexpected token inside string #{token}"
        end

        if @lexer.peek[0] == TOKENS[:is]
          node = Branch.new([@lexer.consume])
          waiting_for_endline = true
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
          scope << node
        end
        case token[0]
        when TOKENS[:newline]
          if waiting_for_endline
            scope.pop
            waiting_for_endline = false
          end
        when TOKENS[:eof]
          eof = true
        when TOKENS[:statement]
          arr = [token]

          # Check if value is associated with a statement
          if lexer.peek(2)[0] == TOKENS[:is]
            arr << @lexer.consume
            arr << @lexer.consume
          end
          # Check if statement has an associated is
          if lexer.peek(1)[0] == TOKENS[:is]
            arr << @lexer.consume
          end
          node = Branch.new(arr)
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
          scope << node
        when TOKENS[:if]
          node = Branch.new([token])
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
          scope << node
        when TOKENS[:else]
          scope.pop
          node = Branch.new([token])
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
          scope << node
        when TOKENS[:end]
          scope.pop
          item = Item.new(token)
          if scope.empty?
            tree << item
          else
            scope.last << item
          end
        when TOKENS[:string_mark]
          string = !string
          if string
            node = Branch.new([token])
            if scope.empty?
              tree << node
            else
              scope.last << node
            end
            scope << node
          else
            item = Item.new([token])
            if scope.empty?
              raise "BabaParser: Unexpected token #{token} outside of string"
            else
              scope.last << item
            end
            scope.pop
          end
        when TOKENS[:string]
          node = Item.new(token)
          if scope.empty?
            raise "BabaParser: Unexpected string outside in empty scope"
          else
            scope.last << node
          end
        else
          item = Item.new(token)
          if scope.empty?
            tree << item
          else
            scope.last << item
          end
        end
      end
      return tree
    end

    class Item
      def initialize(token)
        @token = token
      end

      def token
        @token
      end

      def <<(item)
        @token << item
      end
    end

    class Branch
      def initialize(parent, children = [])
        @parent = parent
        @children = children
      end

      def parent
        @parent
      end

      def [](index)
        @children[index]
      end

      def <<(child)
        @children << child
      end

      def children
        @children
      end

      def size
        @children.size
      end
    end
  end
end
