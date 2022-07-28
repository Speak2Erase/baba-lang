require "ap"

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

        if @lexer.peek[0] == TOKENS[:is] && token[0] == TOKENS[:var]
          node = Node.new([@lexer.consume])
          waiting_for_endline = true
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
          scope << node
        end
        case token[0]
        when TOKENS[:command]
          node = Node.new([token])
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
          scope << node
          waiting_for_endline = true
        when TOKENS[:newline]
          if waiting_for_endline && !string
            scope.pop
            waiting_for_endline = false
          end
          if scope.empty?
            tree << Node.new([token])
          else
            scope.last << Node.new([token])
          end
        when TOKENS[:eof]
          eof = true
          tree << Node.new([token])
        when TOKENS[:statement]
          arr = [token]

          # Check if value is associated with a statement
          if lexer.peek(2)[0] == TOKENS[:is]
            arr << @lexer.consume
            arr << @lexer.consume
          else
            if lexer.peek[0] == TOKENS[:is]
              # Check if statement has an associated is
              arr << @lexer.consume
            else
              raise "BabaParser: Unexpected token #{lexer.peek[0]} on line #{token[2]}, #{token[1]}, expected :token_is"
            end
          end
          node = Node.new(arr)
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
          scope << node
        when TOKENS[:if]
          node = Node.new([token])
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
          scope << node
        when TOKENS[:else]
          scope.pop
          node = Node.new([token])
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
          scope << node
        when TOKENS[:end]
          scope.pop
          node = Node.new([token])
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
        when TOKENS[:string_mark]
          string = !string
          if string
            node = Node.new([token])
            if scope.empty?
              tree << node
            else
              scope.last << node
            end
            scope << node
          else
            node = Node.new([token])
            if scope.empty?
              raise "BabaParser: Unexpected token #{token} outside of string"
            else
              scope.last << node
            end
            scope.pop
          end
        when TOKENS[:string]
          node = Node.new([token])
          if scope.empty?
            raise "BabaParser: Unexpected string outside in empty scope"
          elsif scope.last.parent[0][0] != TOKENS[:string_mark]
            raise "BabaParser: Unexpected string outside of string mark, scope: #{scope.last.parent[0][0]}"
          else
            scope.last << node
          end
        else
          node = Node.new([token])
          if scope.empty?
            tree << node
          else
            scope.last << node
          end
        end
      end
      return tree
    end

    class Node
      include Enumerable

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

      def each(&block)
        @children.each(&block)
      end
    end
  end
end
