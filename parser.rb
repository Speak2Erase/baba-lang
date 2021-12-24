module Parser
  module Tokenizer
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
    }
    KEYWORDS = {
      "if" => TOKENS[:if],
      "else" => TOKENS[:else],
    }

    COMMANDS = []

    class << self
      def tokenize(string)
        tokens = {}
        line_number = 0
        # Iterate through each line
        string.each_line do |line|
          line.strip!
          # Add a newline as a terminator
          line += "\n"
          line_tokens = []

          current_token = ""
          string = false
          # Iterate through each character
          line.each_char do |char|
            current_token << char
            # Set string flag if we're in a string
            if char == '"'
              string = !string
            end

            if string && char == "\n"
              raise "Unterminated string on line #{line_number}"
            end

            # Assemble the token until we reach a space, marking the end of the token
            next unless (char == " " && !string) or char == "\n"
            # Remove the space because we don't need it anymore
            current_token.strip!

            # Figure out what the hell the token is
            case current_token
            when "is" || "are"
              line_tokens << [TOKENS[:is], current_token]
              current_token = ""
            when /\Aend\w*\z/
              line_tokens << [TOKENS[:end], current_token]
              current_token = ""
            when /\$\w*/
              line_tokens << [TOKENS[:statement], current_token]
              current_token = ""
            when "if"
              line_tokens << [TOKENS[:if], current_token]
              current_token = ""
            when "else"
              line_tokens << [TOKENS[:else], current_token]
              current_token = ""
            when /(on|off|true|false)/
              line_tokens << [TOKENS[:bool], current_token]
              current_token = ""
            when /\A\d*\z/
              line_tokens << [TOKENS[:int], current_token]
              current_token = ""
            when /\A\d*\.\d*\z/
              line_tokens << [TOKENS[:float], current_token]
              current_token = ""
            when />>.*\z/
              line_tokens << [TOKENS[:comment], current_token]
              current_token = ""
            when /".*"/
              line_tokens << [TOKENS[:string], current_token]
              current_token = ""
            else
              line_tokens << [TOKENS[:var], current_token]
              current_token = ""
            end
          end
          line_tokens << TOKENS[:newline]
          tokens[line_number] = line_tokens
          line_number += 1
        end
        return tokens
      end
    end
  end
end

code = <<-CODE
$event is
    x is 20
    y is 40 
    id is 10
    name is test
    $page 1 is
        trigger is action
        move_animation is on

        $graphic is
            name is test
            hue is 0
            direction is down
            step is 0
            blending is normal
            opacity is 255
        endgraphic
    
        $condition is
            switch 5 is on
        endcondition
    
        $movement is 
            type is fixed
            speed is 3
            frequency is 3
        endmovement
    
        $commands are
            say "hello world!"
            say "[FUCK]"
            $textbox
                position is middle
                window is hidden
            endtextbox
            $choices is 
                choices are "yes", "no"
                cancel is 1
                if 1
                    say "test"
                endif
                if 2
                    say "test"
                endif
            endchoices
            
        endcommands

    endpage
endevent
CODE

require "ap"

ap Parser::Tokenizer.tokenize(code)
