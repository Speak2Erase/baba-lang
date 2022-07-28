class KekeParser
macro
    DIGIT   [0-9]
    ALPHA   ([a-z]|_)\w*
    BLANK   ([\ \t]+)
    NEWLINE (\n|\r\n)
    COMMENT (\>>.*)
    STATEMENT (\$.*)

rule
    {BLANK}                     # No action
    {NEWLINE}                   { [:SPLIT, text] }
    {COMMENT}                   # No action
    {DIGIT}+                    { [:LITERAL, text.to_i] }
    {DIGIT}+\.{DIGIT}+          { [:LITERAL, text.to_f] }
    {STATEMENT}                 { [:STATEMENT, text] }
    \"([^"]*)\"                 { [:LITERAL, text] }
    "true"                      { [:LITERAL, true] }
    "false"                     { [:LITERAL, false] }
    "on"                        { [:LITERAL, true] }
    "off"                       { [:LITERAL, false] }
    "nil"                       { [:LITERAL, nil] }
    "blank"                     { [:LITERAL, nil] }
    ","                         { [:COMMA, text] }
    "is"                        { [:IS, text] }
    "are"                       { [:IS, text] }
    "end"                       { [:END, text] }

# Commands
    "say"                       { [:COMMAND, text]}
    "text_options"              { [:COMMAND, text]}
    "switch"                    { [:COMMAND, text]}
    "variable"                  { [:COMMAND, text]}
    "self_switch"               { [:COMMAND, text]}
    "input_number"              { [:COMMAND, text]}
    "wait"                      { [:COMMAND, text]}
    "exit"                      { [:COMMAND, text]}
    "erase"                     { [:COMMAND, text]}
    "common_event"              { [:COMMAND, text]}
    "label"                     { [:COMMAND, text]}
    "jump"                      { [:COMMAND, text]}
    "items"                     { [:COMMAND, text]}
    "timer"                     { [:COMMAND, text]}
    "weapons"                   { [:COMMAND, text]}
    "armor"                     { [:COMMAND, text]}
    "party"                     { [:COMMAND, text]}
    "windowskin"                { [:COMMAND, text]}
    "battle_bgm"                { [:COMMAND, text]}
    "battle_endme"              { [:COMMAND, text]}
    "save_access"               { [:COMMAND, text]}
    "menu_access"               { [:COMMAND, text]}
    "encounter"                 { [:COMMAND, text]}
    "transfer"                  { [:COMMAND, text]}
    "move_event"                { [:COMMAND, text]}
    "scroll"                    { [:COMMAND, text]}
    "map_settings"              { [:COMMAND, text]}
    "fog_tone"                  { [:COMMAND, text]}
    "fog_opacity"               { [:COMMAND, text]}
    "animation"                 { [:COMMAND, text]}
    "transparent"               { [:COMMAND, text]}
    "wait_for_move"             { [:COMMAND, text]}
    "prepare_for_transition"    { [:COMMAND, text]}
    "transition"                { [:COMMAND, text]}
    "screen_tone"               { [:COMMAND, text]}
    "flash"                     { [:COMMAND, text]}
    "shake"                     { [:COMMAND, text]}
    "picture"                   { [:COMMAND, text]}
    "move_picture"              { [:COMMAND, text]}
    "rotate_picture"            { [:COMMAND, text]}
    "tint_picture"              { [:COMMAND, text]}
    "erase_picture"             { [:COMMAND, text]}
    "weather"                   { [:COMMAND, text]}
    "bgm"                       { [:COMMAND, text]}
    "bgs"                       { [:COMMAND, text]}
    "fade_bgm"                  { [:COMMAND, text]}
    "fade_bgs"                  { [:COMMAND, text]}
    "memorize_sound"            { [:COMMAND, text]}
    "restore_sound"             { [:COMMAND, text]}
    "me"                        { [:COMMAND, text]}
    "se"                        { [:COMMAND, text]}
    "stop_se"                   { [:COMMAND, text]}
    "battle"                    { [:COMMAND, text]}
    "shop"                      { [:COMMAND, text]}
    "name_input"                { [:COMMAND, text]}
    "hp"                        { [:COMMAND, text]}
    "sp"                        { [:COMMAND, text]}
    "state"                     { [:COMMAND, text]}
    "recover_all"               { [:COMMAND, text]}
    "exp"                       { [:COMMAND, text]}
    "level"                     { [:COMMAND, text]}
    "parameters"                { [:COMMAND, text]}
    "skills"                    { [:COMMAND, text]}
    "equipment"                 { [:COMMAND, text]}
    "actor_name"                { [:COMMAND, text]}
    "actor_class"               { [:COMMAND, text]}
    "actor_graphic"             { [:COMMAND, text]}
    "enemy_hp"                  { [:COMMAND, text]}
    "enemy_sp"                  { [:COMMAND, text]}
    "enemy_state"               { [:COMMAND, text]}
    "recover_enemy"             { [:COMMAND, text]}
    "enemy_appearance"          { [:COMMAND, text]}
    "enemy_transform"           { [:COMMAND, text]}
    "show_battle_animation"     { [:COMMAND, text]}
    "deal_damage"               { [:COMMAND, text]}
    "force_action"              { [:COMMAND, text]}
    "abort_battle"              { [:COMMAND, text]}
    "call_menu"                 { [:COMMAND, text]}
    "call_save"                 { [:COMMAND, text]}
    "gameover"                  { [:COMMAND, text]}
    "return_title"              { [:COMMAND, text]}
    "eval"                      { [:COMMAND, text]}
    "raw_command"               { [:COMMAND, text]}

# Move commands
    "move"                      { [:MOVE_COMMAND, text]}
    "step"                      { [:MOVE_COMMAND, text]}
    "jump"                      { [:MOVE_COMMAND, text]}
    "turn"                      { [:MOVE_COMMAND, text]}
    "change_speed"              { [:MOVE_COMMAND, text]}
    "change_frequency"          { [:MOVE_COMMAND, text]}
    "set_move_animation"        { [:MOVE_COMMAND, text]}
    "set_stop_animation"        { [:MOVE_COMMAND, text]}
    "direction_fix"             { [:MOVE_COMMAND, text]}
    "through"                   { [:MOVE_COMMAND, text]}
    "always_on_top"             { [:MOVE_COMMAND, text]}
    "graphic"                   { [:MOVE_COMMAND, text]}
    "opacity"                   { [:MOVE_COMMAND, text]}
    "blending"                  { [:MOVE_COMMAND, text]}
    "eval_move"                 { [:MOVE_COMMAND, text]}

# Property
    {ALPHA}                     { [:PROPERTY, text]}

end
