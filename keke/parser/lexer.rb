require_relative "classes"

class KekeParser
  class Lexer
    TOKENS = {
      :is => :token_is,
      :command => :token_command,
      :var => :token_variable,
      :int => :token_integer,
      :float => :token_float,
      :bool => :token_boolean,
      :comment => :token_comment,
      :end => :token_endstatement,
      :statement => :token_statement,
      :newline => :token_endline,
      :if => :token_if,
      :else => :token_else,
      :string => :token_string,
      :string_mark => :token_string_mark,
      :constant => :token_constant,
      :eof => :token_eof,
      :sof => :token_sof,
      :movecommand => :token_movecommand,
    }
    KEYWORDS = {
      "if" => TOKENS[:if],
      "else" => TOKENS[:else],
    }

    COMMANDS = %w[
      say
      text_options
      switch
      variable
      self_switch
      input_number
      wait
      exit
      erase
      common_event
      label
      jump
      items
      timer
      weapons
      armor
      party
      windowskin
      battle_bgm
      battle_endme
      save_access
      menu_access
      encounter
      transfer
      move_event
      scroll
      map_settings
      fog_tone
      fog_opacity
      animation
      transparent
      wait_for_move
      prepare_for_transition
      transition
      screen_tone
      flash
      shake
      picture
      move_picture
      rotate_picture
      tint_picture
      erase_picture
      weather
      bgm
      bgs
      fade_bgm
      fade_bgs
      memorize_sound
      restore_sound
      me
      se
      stop_se
      battle
      shop
      name_input
      hp
      sp
      state
      recover_all
      exp
      level
      parameters
      skills
      equipment
      actor_name
      actor_class
      actor_graphic
      enemy_hp
      enemy_sp
      enemy_state
      recover_enemy
      enemy_appearance
      enemy_transform
      show_battle_animation
      deal_damage
      force_action
      abort_battle
      call_menu
      call_save
      gameover
      return_title
      eval
      raw_command
    ]
    MOVE_COMMANDS = %w[
      move
      step
      jump
      turn
      change_speed
      change_frequency
      set_move_animation
      set_stop_animation
      direction_fix
      through
      always_on_top
      graphic
      opacity
      blending
      eval
    ]

    def initialize(string)
      tokens = {}
      line_number = 0
      # Iterate through each line
      in_string = false
      statements = []
      string.each_line do |line|
        line.strip!
        # Add a newline as a terminator
        line += "\n"
        line_tokens = []

        current_token = ""
        comment = false
        previous_char = ""
        end_statement = false
        # Iterate through each character
        line.each_char do |char|
          current_token << char
          # Set string flag if we're in a string
          if char == '"' && previous_char != '\\'
            in_string = !in_string
          end
          if current_token == ">>" && previous_char != '\\'
            comment = true
          end
          if current_token == "end" && previous_char != '\\'
            end_statement = true
          end

          # Assemble the token until we reach a space, marking the end of the token, or we're in a string
          next unless (char == " " && !in_string && !comment && !end_statement) or char == "\n"
          # Remove the space because we don't need it anymore
          current_token.strip!

          if COMMANDS.include?(current_token)
            line_tokens << [TOKENS[:command], current_token]
            current_token = ""
            next
          end

          if MOVE_COMMANDS.include?(current_token)
            unless statements.empty?
              if statements.last[1] == "$move_route"
                line_tokens << [TOKENS[:movecommand], current_token]
                current_token = ""
                next
              end
            end
          end

          # Figure out what the hell the token is
          case current_token
          when /(is|are)/
            line_tokens << [TOKENS[:is], current_token]
            current_token = ""
            next
          when /\Aend \w*\z/
            line_tokens << [TOKENS[:end], current_token]
            current_token = ""
            statements.pop
            next
          when /\$\w*/
            line_tokens << [TOKENS[:statement], current_token]
            statements << [TOKENS[:statement], current_token]
            current_token = ""
            next
          when "if"
            line_tokens << [TOKENS[:if], current_token]
            current_token = ""
            next
          when "else"
            line_tokens << [TOKENS[:else], current_token]
            current_token = ""
            next
          when /\A(on|off|true|false)\z/
            line_tokens << [TOKENS[:bool], current_token]
            current_token = ""
            next
          when /\A\d*\z/
            line_tokens << [TOKENS[:int], current_token]
            current_token = ""
            next
          when /\A\d*\.\d*\z/
            line_tokens << [TOKENS[:float], current_token]
            current_token = ""
            next
          when />>.*\z/
            line_tokens << [TOKENS[:comment], current_token]
            current_token = ""
            comment = false
            next
          when /".*"/
            line_tokens << [TOKENS[:string_mark], '"']
            line_tokens << [TOKENS[:string], current_token]
            line_tokens << [TOKENS[:string_mark], '"']
            current_token = ""
            next
          end

          if current_token.upcase == current_token
            line_tokens << [TOKENS[:constant], current_token]
            current_token = ""
            next
          end

          if in_string && current_token.match(/.*"/)
            line_tokens << [TOKENS[:string_mark], '"']
            line_tokens << [TOKENS[:string], current_token]
            current_token = ""
            next
          end

          if !in_string && current_token.match(/".*/)
            line_tokens << [TOKENS[:string], current_token]
            line_tokens << [TOKENS[:string_mark], '"']
            current_token = ""
            next
          end

          line_tokens << [TOKENS[:var], current_token]
          current_token = ""
          previous_char = char
        end
        line_tokens << [TOKENS[:newline], "\n"]
        tokens[line_number] = line_tokens
        line_number += 1
      end
      @tokens = tokens
      @tokens[@tokens.size] = [TOKENS[:eof], ""]
      @index = -1

      @tokenstream = []
      @tokens.each do |line_number, line_tokens|
        line_tokens.each do |token_type, token|
          @tokenstream << [token_type, token, line_number + 1]
        end
      end
    end

    # Returns the nth token in the stream
    def peek(index = 1)
      return @tokenstream[@index + index]
    end

    # Delete the next token in the stream and return it
    def consume(index = 1)
      @index += index
      return @tokenstream[@index]
    end
  end
end
