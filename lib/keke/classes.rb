class Color
  attr_accessor :red, :green, :blue, :alpha

  def initialize(red = 255, green = 255, blue = 255, alpha = 255)
    @red = red
    @green = green
    @blue = blue
    @alpha = alpha
  end

  def initialize(hash)
    @red = hash["red"]
    @green = hash["green"]
    @blue = hash["blue"]
    @alpha = hash["alpha"]
  end

  def hash
    dump = {
      red: @red,
      green: @green,
      blue: @blue,
      alpha: @alpha,
    }
  end

  def _dump(limit)
    [@red, @green, @blue, @alpha].pack("EEEE")
  end

  def self._load(obj)
    data = *obj.unpack("EEEE")
    s_hash = {
      red: data[0],
      green: data[1],
      blue: data[2],
      alpha: data[3],
    }
    hash = {}
    s_hash.each do |key, value|
      hash[key.to_s] = value
    end
    Color.new hash
  end
end

class Table
  def initialize(hash, resize = true)
    @num_of_dimensions = hash["dimensions"]
    @xsize = hash["width"]
    @ysize = hash["height"]
    @zsize = hash["depth"]
    @num_of_elements = hash["size"]
    @elements = []
    if @num_of_dimensions > 1 && !resize
      hash["elements"].each_with_index do |value, uindex|
        @elements << []
        value.each_with_index do |value, index|
          @elements[uindex] << eval(value) #!Yep, you can do this to turn strings back into arrays
        end
      end
    else
      @elements = hash["elements"]
    end

    if resize
      if @num_of_dimensions > 1
        if @xsize > 1
          @elements = @elements.each_slice(@xsize).to_a
        else
          @elements = @elements.map { |element| [element] }
        end
      end
      if @num_of_dimensions > 2
        if @ysize > 1
          @elements = @elements.each_slice(@ysize).to_a
        else
          @elements = @elements.map { |element| [element] }
        end
      end
    end
  end

  def hash
    dump = {
      dimensions: @num_of_dimensions,
      width: @xsize,
      height: @ysize,
      depth: @zsize,
      size: @num_of_elements,
      elements: [],
    } #.pack("VVVVVv*")

    if @num_of_dimensions > 1
      @elements.each_with_index do |value, uindex|
        dump[:elements] << []
        value.each_with_index do |value, index|
          dump[:elements][uindex] << value.to_s
        end
      end
    else
      dump[:elements] = *@elements
    end

    dump
  end

  def _dump(limit)
    [@num_of_dimensions, @xsize, @ysize, @zsize, @num_of_elements, *@elements.flatten].pack("VVVVVv*")
  end

  def self._load(obj)
    data = obj.unpack("VVVVVv*")
    @num_of_dimensions, @xsize, @ysize, @zsize, @num_of_elements, *@elements = *data
    s_hash = {
      dimensions: @num_of_dimensions,
      width: @xsize,
      height: @ysize,
      depth: @zsize,
      size: @num_of_elements,
      elements: [],
    }
    hash = {}
    s_hash.each do |key, value|
      hash[key.to_s] = value
    end
    hash["elements"] = *@elements

    Table.new(hash)
  end
end

class Tone
  attr_accessor :red, :green, :blue, :gray

  def initialize(red = 0, green = 0, blue = 0, gray = 0)
    @red = red
    @green = green
    @blue = blue
    @gray = gray
  end

  def initialize(hash = {})
    @red = hash["red"]
    @green = hash["green"]
    @blue = hash["blue"]
    @gray = hash["gray"]
  end

  def hash
    dump = {
      red: @red,
      green: @green,
      blue: @blue,
      gray: @gray,
    }
  end

  def _dump(limit)
    [@red, @green, @blue, @gray].pack("EEEE")
  end

  def self._load(obj)
    data = *obj.unpack("EEEE")
    s_hash = {
      "red": data[0],
      "green": data[1],
      "blue": data[2],
      "gray": data[3],
    }
    hash = {}
    s_hash.each do |key, value|
      hash[key.to_s] = value
    end
    Tone.new hash
  end
end

module RPG
  class Event
    def initialize(hash)
      @id = hash["id"]
      @name = hash["name"]
      @x = hash["x"]
      @y = hash["y"]
      @pages = []
      hash["pages"].each_with_index do |value|
        @pages << RPG::Event::Page.new(value)
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        x: @x,
        y: @y,
        pages: [],
      }
      @pages.each_with_index do |value|
        dump[:pages] << value.hash
      end
      dump
    end

    class Page
      def initialize(hash)
        @condition = RPG::Event::Page::Condition.new hash["condition"]
        @graphic = RPG::Event::Page::Graphic.new hash["graphic"]
        @move_type = hash["move_type"]
        @move_speed = hash["move_speed"]
        @move_frequency = hash["move_frequency"]
        @move_route = RPG::MoveRoute.new hash["move_route"]
        @walk_anime = hash["walk_anime"]
        @step_anime = hash["step_anime"]
        @direction_fix = hash["direction_fix"]
        @through = hash["through"]
        @always_on_top = hash["always_on_top"]
        @trigger = hash["trigger"]
        @list = []
        hash["list"].each_with_index do |value|
          @list << RPG::EventCommand.new(value)
        end
      end

      def hash
        dump = {
          condition: "",
          graphic: "",
          move_type: @move_type,
          move_speed: @move_speed,
          move_frequency: @move_frequency,
          move_route: "",
          walk_anime: @walk_anime,
          step_anime: @step_anime,
          direction_fix: @direction_fix,
          through: @through,
          always_on_top: @always_on_top,
          trigger: @trigger,
          list: [],
        }
        @list.each_with_index do |value|
          dump[:list] << value.hash
        end
        dump[:condition] = @condition.hash
        dump[:graphic] = @graphic.hash
        dump[:move_route] = @move_route.hash
        dump
      end

      class Condition
        def initialize(hash)
          @switch1_valid = hash["switch1_valid"]
          @switch2_valid = hash["switch2_valid"]
          @variable_valid = hash["variable_valid"]
          @self_switch_valid = hash["self_switch_valid"]
          @switch1_id = hash["switch1_id"]
          @switch2_id = hash["switch2_id"]
          @variable_id = hash["variable_id"]
          @variable_value = hash["variable_value"]
          @self_switch_ch = hash["self_switch_ch"]
        end

        def hash
          dump = {
            switch1_valid: @switch1_valid,
            switch2_valid: @switch2_valid,
            variable_valid: @variable_valid,
            self_switch_valid: @self_switch_valid,
            switch1_id: @switch1_id,
            switch2_id: @switch2_id,
            variable_id: @variable_id,
            variable_value: @variable_value,
            self_switch_ch: @self_switch_ch,
          }
        end
      end

      class Graphic
        def initialize(hash)
          @tile_id = hash["tile_id"]
          @character_name = hash["character_name"]
          @character_hue = hash["character_hue"]
          @direction = hash["direction"]
          @pattern = hash["pattern"]
          @opacity = hash["opacity"]
          @blend_type = hash["blend_type"]
        end

        def hash
          dump = {
            tile_id: @tile_id,
            character_name: @character_name,
            character_hue: @character_hue,
            direction: @direction,
            pattern: @pattern,
            opacity: @opacity,
            blend_type: @blend_type,
          }
        end
      end
    end
  end

  class EventCommand
    def initialize(hash)
      @code = hash["code"]
      @indent = hash["indent"]
      @parameters = []
      hash["parameters"].each_with_index do |value|
        if value.is_a?(Hash)
          if hash["code"] == 250 || hash["code"] == 249 || hash["code"] == 241 || hash["code"] == 242 || hash["code"] == 245
            @parameters << RPG::AudioFile.new(value)
          elsif hash["code"] == 223 || hash["code"] == 234 || hash["code"] == 205
            @parameters << Tone.new(value)
          elsif hash["code"] == 224
            @parameters << Color.new(value)
          elsif hash["code"] == 509
            @parameters << RPG::MoveCommand.new(value)
          elsif hash["code"] == 209
            @parameters << RPG::MoveRoute.new(value)
          end
        else
          @parameters << value
        end
      end
    end

    def hash
      dump = {
        code: @code,
        indent: @indent,
        parameters: [],
      }
      @parameters.each_with_index do |value|
        if value.to_s.match(/#<RPG::/) || value.to_s.match(/#<Tone:/) || value.to_s.match(/#<Color:/) || value.to_s.match(/#<Table:/)
          dump[:parameters] << value.hash
        elsif value.is_a? String
          if value.encoding.to_s != "UTF-8"
            dump[:parameters] << value.force_encoding("iso-8859-1").encode("utf-8")
          else
            dump[:parameters] << value
          end
        else
          dump[:parameters] << value
        end
      end
      dump
    end
  end

  class MoveRoute
    def initialize(hash)
      @repeat = hash["repeat"]
      @skippable = hash["skippable"]
      @list = []
      hash["list"].each_with_index do |value|
        @list << RPG::MoveCommand.new(value)
      end
    end

    def hash
      dump = {
        repeat: @repeat,
        skippable: @skippable,
        list: [],
      }
      @list.each_with_index do |value|
        dump[:list] << value.hash
      end
      dump
    end
  end

  class MoveCommand
    def initialize(hash)
      @code = hash["code"]
      @parameters = []
      hash["parameters"].each_with_index do |value|
        if value.to_s.match(/#<RPG::/)
          @parameters << RPG::AudioFile.new(value)
        elsif value.to_s.match(/#<Tone:/)
          @parameters << Tone.new(value)
        elsif value.to_s.match(/#<Color:/)
          @parameters << Color.new(value)
        elsif value.to_s.match(/#<Table:/)
          @parameters << Table.new(value, false)
        else
          @parameters << value
        end
      end
    end

    def hash
      dump = {
        code: @code,
        parameters: [],
      }
      @parameters.each_with_index do |value|
        if value.to_s.match(/#<RPG::/) || value.to_s.match(/#<Tone:/) || value.to_s.match(/#<Color:/) || value.to_s.match(/#<Table:/)
          dump[:parameters] << value.hash
        elsif value.is_a? String
          dump[:parameters] << value.force_encoding("iso-8859-1").encode("utf-8")
        else
          dump[:parameters] << value
        end
      end
      dump
    end
  end

  class Map
    def initialize(hash)
      @tileset_id = hash["tileset_id"]
      @width = hash["width"]
      @height = hash["height"]
      @autoplay_bgm = hash["autoplay_bgm"]
      @autoplay_bgs = hash["autoplay_bgs"]
      @bgm = RPG::AudioFile.new hash["bgm"]
      @bgs = RPG::AudioFile.new hash["bgs"]
      @encounter_list = hash["encounter_list"]
      @encounter_step = hash["encounter_step"]
      @data = Table.new(hash["data"], false)
      @events = {}
      events = hash["events"].sort_by { |key| key }.to_h
      events.each do |key, value|
        @events[key.to_i] = RPG::Event.new value
      end
    end

    def hash
      dump = {
        tileset_id: @tileset_id,
        width: @width,
        height: @height,
        autoplay_bgm: @autoplay_bgm,
        bgm: @bgm.hash,
        autoplay_bgs: @autoplay_bgs,
        bgs: @bgs.hash,
        encounter_list: @encounter_list,
        encounter_step: @encounter_step,
        events: {},
        data: @data.hash,
      }
      events = @events.sort_by { |key| key }.to_h
      events.each do |key, value|
        dump[:events][key] = value.hash
      end
      dump
    end
  end

  class MapInfo
    attr_accessor :order

    def initialize(hash)
      @name = hash["name"]
      @parent_id = hash["parent_id"]
      @order = hash["order"]
      @expanded = hash["expanded"]
      @scroll_x = hash["scroll_x"]
      @scroll_y = hash["scroll_y"]
    end

    def hash
      dump = {
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        parent_id: @parent_id,
        order: @order,
        expanded: @expanded,
        scroll_x: @scroll_x,
        scroll_y: @scroll_y,
      }
    end
  end

  class AudioFile
    def initialize(hash)
      @name = hash["name"]
      @volume = hash["volume"]
      @pitch = hash["pitch"]
    end

    def hash
      dump = {
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        volume: @volume,
        pitch: @pitch,
      }
    end
  end

  class System
    def initialize(hash)
      hash.each do |key, value|
        if value.is_a?(Hash)
          if value["volume"] != nil
            eval("@#{key.to_s}=RPG::AudioFile.new(value)")
          else
            eval("@#{key.to_s}=RPG::System::Words.new(value)")
          end
        else
          eval("@#{key.to_s}=value")
        end
      end
    end

    def hash
      dump = {
        magic_number: @magic_number,
        party_members: @party_members,
        elements: @elements,
        switches: @switches,
        variables: @variables,
        windowskin_name: @windowskin_name,
        title_name: @title_name,
        gameover_name: @gameover_name,
        battle_transition: @battle_transition,

        title_bgm: @title_bgm.hash,
        battle_bgm: @battle_bgm.hash,
        battle_end_me: @battle_end_me.hash,
        gameover_me: @gameover_me.hash,
        cursor_se: @cursor_se.hash,
        decision_se: @decision_se.hash,
        cancel_se: @cancel_se.hash,
        buzzer_se: @buzzer_se.hash,
        equip_se: @equip_se.hash,
        shop_se: @shop_se.hash,
        save_se: @save_se.hash,
        load_se: @load_se.hash,
        battle_start_se: @battle_start_se.hash,
        escape_se: @escape_se.hash,
        actor_collapse_se: @actor_collapse_se.hash,
        enemy_collapse_se: @enemy_collapse_se.hash,

        words: @words.hash,
        test_battlers: [],
        test_troop_id: @test_troop_id,
        start_map_id: @start_map_id,
        start_x: @start_x,
        start_y: @start_y,
        battleback_name: @battleback_name,
        battler_name: @battler_name,
        battler_hue: @battler_hue,
        edit_map_id: @edit_map_id,
      }
      @test_battlers.each_with_index do |value, index|
        dump[:test_battlers] << value.hash
      end
      dump
    end

    class Words
      def initialize(hash)
        hash.each do |key, value|
          eval("@#{key.to_s}=value")
        end
      end

      def hash
        dump = {
          gold: @gold,
          hp: @hp,
          sp: @sp,
          str: @str,
          dex: @dex,
          agi: @agi,
          int: @int,
          atk: @atk,
          pdef: @pdef,
          mdef: @mdef,
          weapon: @weapon,
          armor1: @armor1,
          armor2: @armor2,
          armor3: @armor3,
          armor4: @armor4,
          attack: @attack,
          skill: @skill,
          guard: @guard,
          item: @item,
          equip: @equip,
        }
      end
    end

    class TestBattler
      def hash
        dump = {
          actor_id: @actor_id,
          level: @level,
          weapon_id: @weapon_id,
          armor1_id: @armor1_id,
          armor2_id: @armor2_id,
          armor3_id: @armor3_id,
          armor4_id: @armor4_id,
        }
      end
    end
  end

  class CommonEvent
    def initialize(hash)
      @id = hash["id"]
      @name = hash["name"]
      @trigger = hash["trigger"]
      @switch_id = hash["switch_id"]
      @list = []
      hash["list"].each_with_index do |value|
        @list << RPG::EventCommand.new(value)
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        trigger: @trigger,
        switch_id: @switch_id,
        list: [],
      }
      @list.each_with_index do |value|
        dump[:list] << value.hash
      end
      dump
    end
  end

  class Tileset
    def initialize(hash)
      hash.each do |key, value|
        if value.is_a?(Hash)
          eval("@#{key.to_s}=Table.new(value, false)")
        else
          eval("@#{key.to_s}=value")
        end
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        tileset_name: @tileset_name,
        autotile_names: @autotile_names,
        panorama_name: @panorama_name,
        panorama_hue: @panorama_hue,
        fog_name: @fog_name,
        fog_hue: @fog_hue,
        fog_opacity: @fog_opacity,
        fog_blend_type: @fog_blend_type,
        fog_zoom: @fog_zoom,
        fog_sx: @fog_sx,
        fog_sy: @fog_sy,
        battleback_name: @battleback_name,
        passages: @passages.hash,
        priorities: @priorities.hash,
        terrain_tags: @terrain_tags.hash,
      }
      dump
    end
  end

  class State
    def initialize(hash)
      hash.each do |key, value|
        eval("@#{key.to_s}=value")
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        animation_id: @animation_id,
        restriction: @restriction,
        nonresistance: @nonresistance,
        zero_hp: @zero_hp,
        cant_get_exp: @cant_get_exp,
        cant_evade: @cant_evade,
        slip_damage: @slip_damage,
        rating: @rating,
        hit_rate: @hit_rate,
        maxhp_rate: @maxhp_rate,
        maxsp_rate: @maxsp_rate,
        str_rate: @str_rate,
        dex_rate: @dex_rate,
        agi_rate: @agi_rate,
        int_rate: @int_rate,
        atk_rate: @atk_rate,
        pdef_rate: @pdef_rate,
        mdef_rate: @mdef_rate,
        eva: @eva,
        battle_only: @battle_only,
        hold_turn: @hold_turn,
        auto_release_prob: @auto_release_prob,
        shock_release_prob: @shock_release_prob,
        guard_element_set: @guard_element_set,
        plus_state_set: @plus_state_set,
        minus_state_set: @minus_state_set,
      }
    end
  end

  class Animation
    class Frame
      def initialize(hash)
        @cell_max = hash["cell_max"]
        @cell_data = Table.new hash["cell_data"], false
      end

      def hash
        dump = {
          cell_max: @cell_max,
          cell_data: @cell_data.hash,
        }
      end
    end

    class Timing
      def initialize(hash)
        @frame = hash["frame"]
        @se = RPG::AudioFile.new hash["se"]
        @flash_scope = hash["flash_scope"]
        @flash_color = Color.new hash["flash_color"]
        @flash_duration = hash["flash_duration"]
        @condition = hash["condition"]
      end

      def hash
        dump = {
          frame: @frame,
          se: @se.hash,
          flash_scope: @flash_scope,
          flash_color: @flash_color.hash,
          flash_duration: @flash_duration,
          condition: @condition,
        }
      end
    end

    def initialize(hash)
      @id = hash["id"]
      @name = hash["name"]
      @animation_name = hash["animation_name"]
      @animation_hue = hash["animation_hue"]
      @position = hash["position"]
      @frame_max = hash["frame_max"]
      @frames = []
      @timings = []
      hash["frames"].each_with_index do |value|
        @frames << RPG::Animation::Frame.new(value)
      end
      hash["timings"].each_with_index do |value|
        @timings << RPG::Animation::Timing.new(value)
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name,
        animation_name: @animation_name,
        animation_hue: @animation_hue,
        position: @position,
        frame_max: @frame_max,
        frames: [],
        timings: [],
      }
      @frames.each_with_index do |value|
        dump[:frames] << value.hash
      end
      @timings.each_with_index do |value|
        dump[:timings] << value.hash
      end
      dump
    end
  end

  class Class
    def initialize(hash)
      @id = hash["id"]
      @name = hash["name"]
      @position = hash["position"]
      @weapon_set = hash["weapon_set"]
      @armor_set = hash["armor_set"]
      @element_ranks = Table.new hash["element_ranks"], false
      @state_ranks = Table.new hash["state_ranks"], false
      @learnings = []
      hash["learnings"].each_with_index do |value|
        @learnings << RPG::Class::Learning.new(value)
      end
    end

    class Learning
      def initialize(hash)
        @level = hash["level"]
        @skill_id = hash["skill_id"]
      end

      def hash
        dump = {
          level: @level,
          skill_id: @skill_id,
        }
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name,
        position: @position,
        weapon_set: @weapon_set,
        armor_set: @armor_set,
        element_ranks: @element_ranks.hash,
        state_ranks: @state_ranks.hash,
        learnings: [],
      }
      @learnings.each_with_index do |value|
        dump[:learnings] << value.hash
      end
      dump
    end
  end

  class Actor
    def initialize(hash)
      hash.each do |key, value|
        if value.is_a?(Hash)
          eval("@#{key.to_s}=Table.new(value, false)") #! We know there is only one hash in here so this is fine
        else
          eval("@#{key.to_s}=value")
        end
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        class_id: @class_id,
        initial_level: @initial_level,
        final_level: @final_level,
        exp_basis: @exp_basis,
        exp_inflation: @exp_inflation,
        character_name: @character_name,
        character_hue: @character_hue,
        battler_name: @battler_name,
        battler_hue: @battler_hue,
        parameters: @parameters.hash,
        weapon_id: @weapon_id,
        armor1_id: @armor1_id,
        armor2_id: @armor2_id,
        armor3_id: @armor3_id,
        armor4_id: @armor4_id,
        weapon_fix: @weapon_fix,
        armor1_fix: @armor1_fix,
        armor2_fix: @armor2_fix,
        armor3_fix: @armor3_fix,
        armor4_fix: @armor4_fix,
      }
    end
  end

  class Skill
    def initialize(hash)
      hash.each do |key, value|
        if value.is_a?(Hash)
          eval("@#{key.to_s}=RPG::AudioFile.new(value)") #! We know there is only one hash in here so this is fine
        else
          eval("@#{key.to_s}=value")
        end
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        icon_name: @icon_name,
        description: @description.force_encoding("iso-8859-1").encode("utf-8"),
        scope: @scope,
        occasion: @occasion,
        animation1_id: @animation1_id,
        animation2_id: @animation2_id,
        menu_se: @menu_se.hash,
        common_event_id: @common_event_id,
        sp_cost: @sp_cost,
        power: @power,
        atk_f: @atk_f,
        eva_f: @eva_f,
        str_f: @str_f,
        dex_f: @dex_f,
        agi_f: @agi_f,
        int_f: @int_f,
        hit: @hit,
        pdef_f: @pdef_f,
        mdef_f: @mdef_f,
        variance: @variance,
        element_set: @element_set,
        plus_state_set: @plus_state_set,
        minus_state_set: @minus_state_set,
      }
      dump
    end
  end

  class Item
    def initialize(hash)
      hash.each do |key, value|
        if value.is_a?(Hash)
          eval("@#{key.to_s}=RPG::AudioFile.new(value)") #! We know there is only one hash in here so this is fine
        else
          eval("@#{key.to_s}=value")
        end
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        icon_name: @icon_name,
        description: @description.force_encoding("iso-8859-1").encode("utf-8"),
        scope: @scope,
        occasion: @occasion,
        animation1_id: @animation1_id,
        animation2_id: @animation2_id,
        menu_se: @menu_se.hash,
        common_event_id: @common_event_id,
        price: @price,
        consumable: @consumable,
        parameter_type: @parameter_type,
        parameter_points: @parameter_points,
        recover_hp_rate: @recover_hp_rate,
        recover_hp: @recover_hp,
        hit: @hit,
        pdef_f: @pdef_f,
        mdef_f: @mdef_f,
        variance: @variance,
        element_set: @element_set,
        plus_state_set: @plus_state_set,
        minus_state_set: @minus_state_set,
      }
    end
  end

  class Weapon
    def initialize(hash)
      hash.each do |key, value|
        eval("@#{key.to_s}=value")
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        icon_name: @icon_name,
        description: @description.force_encoding("iso-8859-1").encode("utf-8"),
        animation1_id: @animation1_id,
        animation2_id: @animation2_id,
        price: @price,
        atk: @atk,
        pdef: @pdef,
        mdef: @mdef,
        str_plus: @str_plus,
        dex_plus: @dex_plus,
        agi_plus: @agi_plus,
        int_plus: @int_plus,
        element_set: @element_set,
        plus_state_set: @plus_state_set,
        minus_state_set: @minus_state_set,
      }
    end
  end

  class Armor
    def initialize(hash)
      hash.each do |key, value|
        eval("@#{key.to_s}=value")
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        icon_name: @icon_name,
        description: @description.force_encoding("iso-8859-1").encode("utf-8"),
        kind: @kind,
        price: @price,
        pdef: @pdef,
        mdef: @mdef,
        eva: @eva,
        str_plus: @str_plus,
        dex_plus: @dex_plus,
        agi_plus: @agi_plus,
        int_plus: @int_plus,
        guard_element_set: @guard_element_set,
        guard_state_set: @guard_state_set,
      }
    end
  end

  class Enemy
    class Action
      def initialize(hash)
        hash.each do |key, value|
          eval("@#{key.to_s}=value")
        end
      end

      def hash
        dump = {
          kind: @kind,
          basic: @basic,
          skill_id: @skill_id,
          condition_turn_a: @condition_turn_a,
          condition_turn_b: @condition_turn_b,
          condition_hp: @condition_hp,
          condition_level: @condition_level,
          condition_switch_id: @condition_switch_id,
          rating: @rating,
        }
      end
    end

    def initialize(hash)
      hash.each do |key, value|
        if value.is_a?(Hash)
          eval("@#{key.to_s}=Table.new(value, false)")
        elsif value.is_a?(Array)
          @actions = []
          value.each_with_index do |value|
            @actions << RPG::Enemy::Action.new(value)
          end
        else
          eval("@#{key.to_s}=value")
        end
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        battler_name: @battler_name,
        battler_hue: @battler_hue,
        maxhp: @maxhp,
        maxsp: @maxsp,
        str: @str,
        dex: @dex,
        agi: @agi,
        int: @int,
        atk: @atk,
        pdef: @pdef,
        mdef: @mdef,
        eva: @eva,
        animation1_id: @animation1_id,
        animation2_id: @animation2_id,
        element_ranks: @element_ranks.hash,
        state_ranks: @state_ranks.hash,
        actions: [],
        exp: @exp,
        gold: @gold,
        item_id: @item_id,
        weapon_id: @weapon_id,
        armor_id: @armor_id,
        treasure_prob: @treasure_prob,
      }
      @actions.each_with_index do |value|
        dump[:actions] << value.hash
      end
      dump
    end
  end

  class Troop
    class Member
      def initialize(hash)
        hash.each do |key, value|
          eval("@#{key.to_s}=value")
        end
      end

      def hash
        dump = {
          enemy_id: @enemy_id,
          x: @x,
          y: @y,
          hidden: @hidden,
          immortal: @immortal,
        }
      end
    end

    class Page
      class Condition
        def initialize(hash)
          hash.each do |key, value|
            eval("@#{key.to_s}=value")
          end
        end

        def hash
          dump = {
            turn_valid: @turn_valid,
            enemy_valid: @enemy_valid,
            actor_valid: @actor_valid,
            switch_valid: @switch_valid,
            turn_a: @turn_a,
            turn_b: @turn_b,
            enemy_index: @enemy_index,
            enemy_hp: @enemy_hp,
            actor_id: @actor_id,
            actor_hp: @actor_hp,
            switch_id: @switch_id,
          }
        end
      end

      def initialize(hash)
        @condition = RPG::Troop::Page::Condition.new hash["condition"]
        @span = hash["span"]
        @list = []
        hash["list"].each_with_index do |value|
          @list << RPG::EventCommand.new(value)
        end
      end

      def hash
        dump = {
          condition: @condition.hash,
          span: @span,
          list: [],
        }
        @list.each_with_index do |value|
          dump[:list] << value.hash
        end
        dump
      end
    end

    def initialize(hash)
      @id = hash["id"]
      @name = hash["name"]
      @members = []
      @pages = []

      hash["members"].each_with_index do |value|
        @members << RPG::Troop::Member.new(value)
      end

      hash["pages"].each_with_index do |value|
        @pages << RPG::Troop::Page.new(value)
      end
    end

    def hash
      dump = {
        id: @id,
        name: @name,
        members: [],
        pages: [],
      }
      @members.each_with_index do |value|
        dump[:members] << value.hash
      end
      @pages.each_with_index do |value|
        dump[:pages] << value.hash
      end
      dump
    end
  end
end

module RPG
  class Map
    def initialize(width, height)
      @tileset_id = 1
      @width = width
      @height = height
      @autoplay_bgm = false
      @bgm = RPG::AudioFile.new
      @autoplay_bgs = false
      @bgs = RPG::AudioFile.new("", 80)
      @encounter_list = []
      @encounter_step = 30
      @data = Table.new(width, height, 3)
      @events = {}
    end

    attr_accessor :tileset_id
    attr_accessor :width
    attr_accessor :height
    attr_accessor :autoplay_bgm
    attr_accessor :bgm
    attr_accessor :autoplay_bgs
    attr_accessor :bgs
    attr_accessor :encounter_list
    attr_accessor :encounter_step
    attr_accessor :data
    attr_accessor :events
  end

  class MapInfo
    def initialize
      @name = ""
      @parent_id = 0
      @order = 0
      @expanded = false
      @scroll_x = 0
      @scroll_y = 0
    end

    attr_accessor :name
    attr_accessor :parent_id
    attr_accessor :order
    attr_accessor :expanded
    attr_accessor :scroll_x
    attr_accessor :scroll_y
  end

  class Event
    class Page
      class Condition
        def initialize
          @switch1_valid = false
          @switch2_valid = false
          @variable_valid = false
          @self_switch_valid = false
          @switch1_id = 1
          @switch2_id = 1
          @variable_id = 1
          @variable_value = 0
          @self_switch_ch = "A"
        end

        attr_accessor :switch1_valid
        attr_accessor :switch2_valid
        attr_accessor :variable_valid
        attr_accessor :self_switch_valid
        attr_accessor :switch1_id
        attr_accessor :switch2_id
        attr_accessor :variable_id
        attr_accessor :variable_value
        attr_accessor :self_switch_ch
      end

      class Graphic
        def initialize
          @tile_id = 0
          @character_name = ""
          @character_hue = 0
          @direction = 2
          @pattern = 0
          @opacity = 255
          @blend_type = 0
        end

        attr_accessor :tile_id
        attr_accessor :character_name
        attr_accessor :character_hue
        attr_accessor :direction
        attr_accessor :pattern
        attr_accessor :opacity
        attr_accessor :blend_type
      end

      def initialize
        @condition = RPG::Event::Page::Condition.new
        @graphic = RPG::Event::Page::Graphic.new
        @move_type = 0
        @move_speed = 3
        @move_frequency = 3
        @move_route = RPG::MoveRoute.new
        @walk_anime = true
        @step_anime = false
        @direction_fix = false
        @through = false
        @always_on_top = false
        @trigger = 0
        @list = [RPG::EventCommand.new]
      end

      attr_accessor :condition
      attr_accessor :graphic
      attr_accessor :move_type
      attr_accessor :move_speed
      attr_accessor :move_frequency
      attr_accessor :move_route
      attr_accessor :walk_anime
      attr_accessor :step_anime
      attr_accessor :direction_fix
      attr_accessor :through
      attr_accessor :always_on_top
      attr_accessor :trigger
      attr_accessor :list
    end

    def initialize(x = 0, y = 0)
      @id = 0
      @name = ""
      @x = x
      @y = y
      @pages = [RPG::Event::Page.new]
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :x
    attr_accessor :y
    attr_accessor :pages
  end

  class EventCommand
    def initialize(code = 0, indent = 0, parameters = [])
      @code = code
      @indent = indent
      @parameters = parameters
    end

    attr_accessor :code
    attr_accessor :indent
    attr_accessor :parameters
  end

  class MoveRoute
    def initialize
      @repeat = true
      @skippable = false
      @list = [RPG::MoveCommand.new]
    end

    attr_accessor :repeat
    attr_accessor :skippable
    attr_accessor :list
  end

  class MoveCommand
    def initialize(code = 0, parameters = [])
      @code = code
      @parameters = parameters
    end

    attr_accessor :code
    attr_accessor :parameters
  end

  class Actor
    def initialize
      @id = 0
      @name = ""
      @class_id = 1
      @initial_level = 1
      @final_level = 99
      @exp_basis = 30
      @exp_inflation = 30
      @character_name = ""
      @character_hue = 0
      @battler_name = ""
      @battler_hue = 0
      @parameters = Table.new(6, 100)
      for i in 1..99
        @parameters[0, i] = 500 + i * 50
        @parameters[1, i] = 500 + i * 50
        @parameters[2, i] = 50 + i * 5
        @parameters[3, i] = 50 + i * 5
        @parameters[4, i] = 50 + i * 5
        @parameters[5, i] = 50 + i * 5
      end
      @weapon_id = 0
      @armor1_id = 0
      @armor2_id = 0
      @armor3_id = 0
      @armor4_id = 0
      @weapon_fix = false
      @armor1_fix = false
      @armor2_fix = false
      @armor3_fix = false
      @armor4_fix = false
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :class_id
    attr_accessor :initial_level
    attr_accessor :final_level
    attr_accessor :exp_basis
    attr_accessor :exp_inflation
    attr_accessor :character_name
    attr_accessor :character_hue
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :parameters
    attr_accessor :weapon_id
    attr_accessor :armor1_id
    attr_accessor :armor2_id
    attr_accessor :armor3_id
    attr_accessor :armor4_id
    attr_accessor :weapon_fix
    attr_accessor :armor1_fix
    attr_accessor :armor2_fix
    attr_accessor :armor3_fix
    attr_accessor :armor4_fix
  end

  class Class
    class Learning
      def initialize
        @level = 1
        @skill_id = 1
      end

      attr_accessor :level
      attr_accessor :skill_id
    end

    def initialize
      @id = 0
      @name = ""
      @position = 0
      @weapon_set = []
      @armor_set = []
      @element_ranks = Table.new(1)
      @state_ranks = Table.new(1)
      @learnings = []
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :position
    attr_accessor :weapon_set
    attr_accessor :armor_set
    attr_accessor :element_ranks
    attr_accessor :state_ranks
    attr_accessor :learnings
  end

  class Skill
    def initialize
      @id = 0
      @name = ""
      @icon_name = ""
      @description = ""
      @scope = 0
      @occasion = 1
      @animation1_id = 0
      @animation2_id = 0
      @menu_se = RPG::AudioFile.new("", 80)
      @common_event_id = 0
      @sp_cost = 0
      @power = 0
      @atk_f = 0
      @eva_f = 0
      @str_f = 0
      @dex_f = 0
      @agi_f = 0
      @int_f = 100
      @hit = 100
      @pdef_f = 0
      @mdef_f = 100
      @variance = 15
      @element_set = []
      @plus_state_set = []
      @minus_state_set = []
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_name
    attr_accessor :description
    attr_accessor :scope
    attr_accessor :occasion
    attr_accessor :animation1_id
    attr_accessor :animation2_id
    attr_accessor :menu_se
    attr_accessor :common_event_id
    attr_accessor :sp_cost
    attr_accessor :power
    attr_accessor :atk_f
    attr_accessor :eva_f
    attr_accessor :str_f
    attr_accessor :dex_f
    attr_accessor :agi_f
    attr_accessor :int_f
    attr_accessor :hit
    attr_accessor :pdef_f
    attr_accessor :mdef_f
    attr_accessor :variance
    attr_accessor :element_set
    attr_accessor :plus_state_set
    attr_accessor :minus_state_set
  end

  class Item
    def initialize
      @id = 0
      @name = ""
      @icon_name = ""
      @description = ""
      @scope = 0
      @occasion = 0
      @animation1_id = 0
      @animation2_id = 0
      @menu_se = RPG::AudioFile.new("", 80)
      @common_event_id = 0
      @price = 0
      @consumable = true
      @parameter_type = 0
      @parameter_points = 0
      @recover_hp_rate = 0
      @recover_hp = 0
      @recover_sp_rate = 0
      @recover_sp = 0
      @hit = 100
      @pdef_f = 0
      @mdef_f = 0
      @variance = 0
      @element_set = []
      @plus_state_set = []
      @minus_state_set = []
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_name
    attr_accessor :description
    attr_accessor :scope
    attr_accessor :occasion
    attr_accessor :animation1_id
    attr_accessor :animation2_id
    attr_accessor :menu_se
    attr_accessor :common_event_id
    attr_accessor :price
    attr_accessor :consumable
    attr_accessor :parameter_type
    attr_accessor :parameter_points
    attr_accessor :recover_hp_rate
    attr_accessor :recover_hp
    attr_accessor :recover_sp_rate
    attr_accessor :recover_sp
    attr_accessor :hit
    attr_accessor :pdef_f
    attr_accessor :mdef_f
    attr_accessor :variance
    attr_accessor :element_set
    attr_accessor :plus_state_set
    attr_accessor :minus_state_set
  end

  class Weapon
    def initialize
      @id = 0
      @name = ""
      @icon_name = ""
      @description = ""
      @animation1_id = 0
      @animation2_id = 0
      @price = 0
      @atk = 0
      @pdef = 0
      @mdef = 0
      @str_plus = 0
      @dex_plus = 0
      @agi_plus = 0
      @int_plus = 0
      @element_set = []
      @plus_state_set = []
      @minus_state_set = []
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_name
    attr_accessor :description
    attr_accessor :animation1_id
    attr_accessor :animation2_id
    attr_accessor :price
    attr_accessor :atk
    attr_accessor :pdef
    attr_accessor :mdef
    attr_accessor :str_plus
    attr_accessor :dex_plus
    attr_accessor :agi_plus
    attr_accessor :int_plus
    attr_accessor :element_set
    attr_accessor :plus_state_set
    attr_accessor :minus_state_set
  end

  class Armor
    def initialize
      @id = 0
      @name = ""
      @icon_name = ""
      @description = ""
      @kind = 0
      @auto_state_id = 0
      @price = 0
      @pdef = 0
      @mdef = 0
      @eva = 0
      @str_plus = 0
      @dex_plus = 0
      @agi_plus = 0
      @int_plus = 0
      @guard_element_set = []
      @guard_state_set = []
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_name
    attr_accessor :description
    attr_accessor :kind
    attr_accessor :auto_state_id
    attr_accessor :price
    attr_accessor :pdef
    attr_accessor :mdef
    attr_accessor :eva
    attr_accessor :str_plus
    attr_accessor :dex_plus
    attr_accessor :agi_plus
    attr_accessor :int_plus
    attr_accessor :guard_element_set
    attr_accessor :guard_state_set
  end

  class Enemy
    class Action
      def initialize
        @kind = 0
        @basic = 0
        @skill_id = 1
        @condition_turn_a = 0
        @condition_turn_b = 1
        @condition_hp = 100
        @condition_level = 1
        @condition_switch_id = 0
        @rating = 5
      end

      attr_accessor :kind
      attr_accessor :basic
      attr_accessor :skill_id
      attr_accessor :condition_turn_a
      attr_accessor :condition_turn_b
      attr_accessor :condition_hp
      attr_accessor :condition_level
      attr_accessor :condition_switch_id
      attr_accessor :rating
    end

    def initialize
      @id = 0
      @name = ""
      @battler_name = ""
      @battler_hue = 0
      @maxhp = 500
      @maxsp = 500
      @str = 50
      @dex = 50
      @agi = 50
      @int = 50
      @atk = 100
      @pdef = 100
      @mdef = 100
      @eva = 0
      @animation1_id = 0
      @animation2_id = 0
      @element_ranks = Table.new(1)
      @state_ranks = Table.new(1)
      @actions = [RPG::Enemy::Action.new]
      @exp = 0
      @gold = 0
      @item_id = 0
      @weapon_id = 0
      @armor_id = 0
      @treasure_prob = 100
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :maxhp
    attr_accessor :maxsp
    attr_accessor :str
    attr_accessor :dex
    attr_accessor :agi
    attr_accessor :int
    attr_accessor :atk
    attr_accessor :pdef
    attr_accessor :mdef
    attr_accessor :eva
    attr_accessor :animation1_id
    attr_accessor :animation2_id
    attr_accessor :element_ranks
    attr_accessor :state_ranks
    attr_accessor :actions
    attr_accessor :exp
    attr_accessor :gold
    attr_accessor :item_id
    attr_accessor :weapon_id
    attr_accessor :armor_id
    attr_accessor :treasure_prob
  end

  class Troop
    class Member
      def initialize
        @enemy_id = 1
        @x = 0
        @y = 0
        @hidden = false
        @immortal = false
      end

      attr_accessor :enemy_id
      attr_accessor :x
      attr_accessor :y
      attr_accessor :hidden
      attr_accessor :immortal
    end

    class Page
      class Condition
        def initialize
          @turn_valid = false
          @enemy_valid = false
          @actor_valid = false
          @switch_valid = false
          @turn_a = 0
          @turn_b = 0
          @enemy_index = 0
          @enemy_hp = 50
          @actor_id = 1
          @actor_hp = 50
          @switch_id = 1
        end

        attr_accessor :turn_valid
        attr_accessor :enemy_valid
        attr_accessor :actor_valid
        attr_accessor :switch_valid
        attr_accessor :turn_a
        attr_accessor :turn_b
        attr_accessor :enemy_index
        attr_accessor :enemy_hp
        attr_accessor :actor_id
        attr_accessor :actor_hp
        attr_accessor :switch_id
      end

      def initialize
        @condition = RPG::Troop::Page::Condition.new
        @span = 0
        @list = [RPG::EventCommand.new]
      end

      attr_accessor :condition
      attr_accessor :span
      attr_accessor :list
    end

    def initialize
      @id = 0
      @name = ""
      @members = []
      @pages = [RPG::BattleEventPage.new]
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :members
    attr_accessor :pages
  end

  class State
    def initialize
      @id = 0
      @name = ""
      @animation_id = 0
      @restriction = 0
      @nonresistance = false
      @zero_hp = false
      @cant_get_exp = false
      @cant_evade = false
      @slip_damage = false
      @rating = 5
      @hit_rate = 100
      @maxhp_rate = 100
      @maxsp_rate = 100
      @str_rate = 100
      @dex_rate = 100
      @agi_rate = 100
      @int_rate = 100
      @atk_rate = 100
      @pdef_rate = 100
      @mdef_rate = 100
      @eva = 0
      @battle_only = true
      @hold_turn = 0
      @auto_release_prob = 0
      @shock_release_prob = 0
      @guard_element_set = []
      @plus_state_set = []
      @minus_state_set = []
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :animation_id
    attr_accessor :restriction
    attr_accessor :nonresistance
    attr_accessor :zero_hp
    attr_accessor :cant_get_exp
    attr_accessor :cant_evade
    attr_accessor :slip_damage
    attr_accessor :rating
    attr_accessor :hit_rate
    attr_accessor :maxhp_rate
    attr_accessor :maxsp_rate
    attr_accessor :str_rate
    attr_accessor :dex_rate
    attr_accessor :agi_rate
    attr_accessor :int_rate
    attr_accessor :atk_rate
    attr_accessor :pdef_rate
    attr_accessor :mdef_rate
    attr_accessor :eva
    attr_accessor :battle_only
    attr_accessor :hold_turn
    attr_accessor :auto_release_prob
    attr_accessor :shock_release_prob
    attr_accessor :guard_element_set
    attr_accessor :plus_state_set
    attr_accessor :minus_state_set
  end

  class Animation
    class Frame
      def initialize
        @cell_max = 0
        @cell_data = Table.new(0, 0)
      end

      attr_accessor :cell_max
      attr_accessor :cell_data
    end

    class Timing
      def initialize
        @frame = 0
        @se = RPG::AudioFile.new("", 80)
        @flash_scope = 0
        @flash_color = Color.new(255, 255, 255, 255)
        @flash_duration = 5
        @condition = 0
      end

      attr_accessor :frame
      attr_accessor :se
      attr_accessor :flash_scope
      attr_accessor :flash_color
      attr_accessor :flash_duration
      attr_accessor :condition
    end

    def initialize
      @id = 0
      @name = ""
      @animation_name = ""
      @animation_hue = 0
      @position = 1
      @frame_max = 1
      @frames = [RPG::Animation::Frame.new]
      @timings = []
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :animation_name
    attr_accessor :animation_hue
    attr_accessor :position
    attr_accessor :frame_max
    attr_accessor :frames
    attr_accessor :timings
  end

  class Tileset
    def initialize
      @id = 0
      @name = ""
      @tileset_name = ""
      @autotile_names = [""] * 7
      @panorama_name = ""
      @panorama_hue = 0
      @fog_name = ""
      @fog_hue = 0
      @fog_opacity = 64
      @fog_blend_type = 0
      @fog_zoom = 200
      @fog_sx = 0
      @fog_sy = 0
      @battleback_name = ""
      @passages = Table.new(384)
      @priorities = Table.new(384)
      @priorities[0] = 5
      @terrain_tags = Table.new(384)
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :tileset_name
    attr_accessor :autotile_names
    attr_accessor :panorama_name
    attr_accessor :panorama_hue
    attr_accessor :fog_name
    attr_accessor :fog_hue
    attr_accessor :fog_opacity
    attr_accessor :fog_blend_type
    attr_accessor :fog_zoom
    attr_accessor :fog_sx
    attr_accessor :fog_sy
    attr_accessor :battleback_name
    attr_accessor :passages
    attr_accessor :priorities
    attr_accessor :terrain_tags
  end

  class CommonEvent
    def initialize
      @id = 0
      @name = ""
      @trigger = 0
      @switch_id = 1
      @list = [RPG::EventCommand.new]
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :trigger
    attr_accessor :switch_id
    attr_accessor :list
  end

  class System
    class Words
      def initialize
        @gold = ""
        @hp = ""
        @sp = ""
        @str = ""
        @dex = ""
        @agi = ""
        @int = ""
        @atk = ""
        @pdef = ""
        @mdef = ""
        @weapon = ""
        @armor1 = ""
        @armor2 = ""
        @armor3 = ""
        @armor4 = ""
        @attack = ""
        @skill = ""
        @guard = ""
        @item = ""
        @equip = ""
      end

      attr_accessor :gold
      attr_accessor :hp
      attr_accessor :sp
      attr_accessor :str
      attr_accessor :dex
      attr_accessor :agi
      attr_accessor :int
      attr_accessor :atk
      attr_accessor :pdef
      attr_accessor :mdef
      attr_accessor :weapon
      attr_accessor :armor1
      attr_accessor :armor2
      attr_accessor :armor3
      attr_accessor :armor4
      attr_accessor :attack
      attr_accessor :skill
      attr_accessor :guard
      attr_accessor :item
      attr_accessor :equip
    end

    class TestBattler
      def initialize
        @actor_id = 1
        @level = 1
        @weapon_id = 0
        @armor1_id = 0
        @armor2_id = 0
        @armor3_id = 0
        @armor4_id = 0
      end

      attr_accessor :actor_id
      attr_accessor :level
      attr_accessor :weapon_id
      attr_accessor :armor1_id
      attr_accessor :armor2_id
      attr_accessor :armor3_id
      attr_accessor :armor4_id
    end

    def initialize
      @magic_number = 0
      @party_members = [1]
      @elements = [nil, ""]
      @switches = [nil, ""]
      @variables = [nil, ""]
      @windowskin_name = ""
      @title_name = ""
      @gameover_name = ""
      @battle_transition = ""
      @title_bgm = RPG::AudioFile.new
      @battle_bgm = RPG::AudioFile.new
      @battle_end_me = RPG::AudioFile.new
      @gameover_me = RPG::AudioFile.new
      @cursor_se = RPG::AudioFile.new("", 80)
      @decision_se = RPG::AudioFile.new("", 80)
      @cancel_se = RPG::AudioFile.new("", 80)
      @buzzer_se = RPG::AudioFile.new("", 80)
      @equip_se = RPG::AudioFile.new("", 80)
      @shop_se = RPG::AudioFile.new("", 80)
      @save_se = RPG::AudioFile.new("", 80)
      @load_se = RPG::AudioFile.new("", 80)
      @battle_start_se = RPG::AudioFile.new("", 80)
      @escape_se = RPG::AudioFile.new("", 80)
      @actor_collapse_se = RPG::AudioFile.new("", 80)
      @enemy_collapse_se = RPG::AudioFile.new("", 80)
      @words = RPG::System::Words.new
      @test_battlers = []
      @test_troop_id = 1
      @start_map_id = 1
      @start_x = 0
      @start_y = 0
      @battleback_name = ""
      @battler_name = ""
      @battler_hue = 0
      @edit_map_id = 1
    end

    attr_accessor :magic_number
    attr_accessor :party_members
    attr_accessor :elements
    attr_accessor :switches
    attr_accessor :variables
    attr_accessor :windowskin_name
    attr_accessor :title_name
    attr_accessor :gameover_name
    attr_accessor :battle_transition
    attr_accessor :title_bgm
    attr_accessor :battle_bgm
    attr_accessor :battle_end_me
    attr_accessor :gameover_me
    attr_accessor :cursor_se
    attr_accessor :decision_se
    attr_accessor :cancel_se
    attr_accessor :buzzer_se
    attr_accessor :equip_se
    attr_accessor :shop_se
    attr_accessor :save_se
    attr_accessor :load_se
    attr_accessor :battle_start_se
    attr_accessor :escape_se
    attr_accessor :actor_collapse_se
    attr_accessor :enemy_collapse_se
    attr_accessor :words
    attr_accessor :test_battlers
    attr_accessor :test_troop_id
    attr_accessor :start_map_id
    attr_accessor :start_x
    attr_accessor :start_y
    attr_accessor :battleback_name
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :edit_map_id
  end

  class AudioFile
    def initialize(name = "", volume = 100, pitch = 100)
      @name = name
      @volume = volume
      @pitch = pitch
    end

    attr_accessor :name
    attr_accessor :volume
    attr_accessor :pitch
  end
end
