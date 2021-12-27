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

  CONSTANTS = []

  ALIASES = {
    "name" => "character_name",
    "hue" => "character_hue",
    "step" => "pattern",
    "walk_animation" => "walk_anime",
    "step_animation" => "step_anime",
    "blending" => "blend_type",
  }

  COMMAND_ALIASES = {
    "say" => 101,
    "switch" => 121,
    "variable" => 122,
    "self_switch" => 123,
  }

  TOKENS = Lexer::TOKENS

  def parse(code)
    eof = false
    ast = AST.parse(Lexer.new(code))

    @scope = []
    @object_scope = []
    @events = {}
    @is = true
    @var = nil
    @string = ""
    @in_string = false
    @in_list = false

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
      when :$commands
        @in_list = true
      end
    when TOKENS[:end]
      if node.parent[0][1] == "end commands"
        in_list = false
      end
      @object_scope.pop
    when TOKENS[:is]
      @is = true
    when TOKENS[:var]
      @var = node.parent[0][1]
      begin
        eval("@object_scope.last.#{@var}")
      rescue
        raise "Variable #{@var} not found" if ALIASES[@var].nil?
        eval("@object_scope.last.#{ALIASES[@var]}")
      end
    when TOKENS[:int]
      value = node.parent[0][1].to_i
      if @is
        begin
          eval("@object_scope.last.#{@var} = #{value}")
        rescue
          raise "Variable #{@var} not found" if ALIASES[@var].nil?
          eval("@object_scope.last.#{ALIASES[@var]} = #{value}")
        end
      end
      @is = false
      @var = nil
    when TOKENS[:bool]
      value = node.parent[0][1].to_b
      if @is
        begin
          eval("@object_scope.last.#{@var} = #{value}")
        rescue
          raise "Variable #{@var} not found" if ALIASES[@var].nil?
          eval("@object_scope.last.#{ALIASES[@var]} = #{value}")
        end
      end
      @is = false
      @var = nil
    when TOKENS[:constant]
      @var = nil
      @is = false
    when TOKENS[:string_mark]
      @in_string = !@in_string
      unless @in_string
        if @is
          begin
            eval("@object_scope.last.#{@var} = #{@string}")
          rescue
            raise "Variable #{@var} not found" if ALIASES[@var].nil?
            eval("@object_scope.last.#{ALIASES[@var]} = #{@string}")
          end
        end
        @is = false
        @var = nil
        @string = ""
      end
    when TOKENS[:string]
      if @in_string
        @string += node.parent[0][1]
      end
    when TOKENS[:command]
      command = RPG::EventCommand.new
      command.code = COMMAND_ALIASES[node.parent[0][1]]

      if !@in_list && @object_scope.last.is_a?(RPG::Event::Page::Condition)
        condition = @object_scope.last
        case command.code
        when 121
          unless condition.switch1_valid
            condition.switch1_valid = true

            condition.switch1_id = node.children[0].parent[0][1].to_i
          else
            condition.switch2_valid = true
            condition.switch2_id = node.children[0].parent[0][1].to_i
          end
        when 122
          condition.variable_id = node.children[0].parent[0][1].to_i
          condition.variable_value = node.children[2].parent[0][1].to_i
          condition.variable_valid = true
          node.children.delete_at(1)
        when 123
        else
          raise "Command #{node.parent[0][1]} is in an improper spot."
        end
        return
      end

      raise "Command #{node.parent[0][1]} not found" if command.code.nil?
      raise "Not inside event $commands" unless @in_list
      raise "Not inside event page" unless @object_scope.last.is_a?(RPG::Event::Page)
      page = @object_scope.last
      page.list << command
    end
  end
end

class String
  def to_b
    return true if self == "true"
    return false if self == "false"
    return true if self == "on"
    return false if self == "off"
    return true if self == "yes"
    return false if self == "no"
    return true if self == "1"
    return false if self == "0"
    raise "Invalid boolean value: #{self}"
  end
end

ap BaBaParser.new.parse(File.read("../example_event.baba")), { raw: true }
