require "ap"

class BaBaParser
  require_relative "parser/lexer"
  require_relative "parser/error"
  require_relative "parser/classes"
  require_relative "parser/ast"

  STATEMENTS = [
    :$event,
    :$page,
    :$movement,
    :$commands,
    :$graphic,
    :$condition,
    :$choices,
    :$textbox,
  ]

  TOKENS = Lexer::TOKENS

  def parse(code)
    eof = false
    ast = AST.parse(Lexer.new(code))
    @scope = []
    @object_scope = []
    @events = {}
    ap ast, { raw: true }
    ast.each do |node|
      process_node(node)
    end
    return @events
  end

  def process_node(node)
    node_work(node)
    @scope << node
    node.each do |child|
      process_node(child)
    end
    @scope.pop
  end

  def node_work(node)
    case node.parent[0][0]
    when TOKENS[:statement]
      case node.parent[0][1].to_sym
      when :$event
        raise "Event created inside event" if !@scope.empty? && @scope.first.parent[0][1] == "$event"
        event = RPG::Event.new
        id = node.parent[1][1].to_i
        event.id = id
        @events[id] = event
        @object_scope << event
      when :$page
        page = RPG::Event::Page.new
        raise "Page is not inside event" unless @scope.last.parent[0][1] == "$event"
        raise "Page is not inside event" unless @object_scope.last.is_a?(RPG::Event)
        event = @object_scope.last
        page_id = node.parent[1][1].to_i - 1

        # Pages start at 1 in the editor and in babalang but at 0 in ruby
        until event.pages.size - 1 >= page_id
          event.pages << RPG::Event::Page.new
        end
        event.pages[page_id] = page

        @object_scope << page
      when :$graphic
        graphic = RPG::Event::Page::Graphic.new
        raise "Graphic is not inside page" unless @scope.last.parent[0][1] == "$page"
        raise "Graphic is not inside page" unless @object_scope.last.is_a?(RPG::Event::Page)
        page = @object_scope.last
        page.graphic = graphic

        @object_scope << graphic
      when :$condition
        condition = RPG::Event::Page::Condition.new
        raise "Condition is not inside page" unless @scope.last.parent[0][1] == "$page"
        raise "Condition is not inside page" unless @object_scope.last.is_a?(RPG::Event::Page)
        page = @object_scope.last
        page.condition = condition

        @object_scope << condition
      when :$move_route
        move_route = RPG::MoveRoute.new
        case @object_scope.last.class.name
        when "RPG::Event::Page"
          page = @object_scope.last
          page.move_route = move_route
        end

        @object_scope << move_route
      end
    when TOKENS[:end]
      @object_scope.pop
    when TOKENS[:is]
    end
  end
end

ap BaBaParser.new.parse(File.read("../example_event.baba")), { raw: true }
