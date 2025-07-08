# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

# See https://www.nushell.sh/book/configuration.html

# ---------------------------------- modules --------------------------------- #

const IMPORTS_FILE = '~/Projects/nushell-scripts/imports.nu' | path expand
source $IMPORTS_FILE

const SYS_COMMANDS_FILE = ('~/.sys-commands.nu' | path expand)
source $SYS_COMMANDS_FILE

use everything.nu *

# ---------------------------- environment config ---------------------------- #

$env.IMPORTS_FILE = $IMPORTS_FILE
$env.SYS_COMMANDS_FILE = $SYS_COMMANDS_FILE
$env.VARS_FILE = ('~/.nu-vars.toml' | path expand)

$env.PROCEDURE_LEVEL = 0
$env.PROCEDURE_DEBUG = true

# $env.LS_COLORS = 'no=0:fi=0:di=1;34:ln=36:pi=33:so=35:bd=1;33:cd=1;33:or=31:mi=05;37;41:ex=01;32:*.tar=01;31:*.tgz=01;31:*.gz=01;31:*.zip=01;31:*.rar=01;31:*.7z=01;31'

# $env.LS_COLORS = 'di=1:fi=0:ln=31:pi=5:so=5:bd=5:cd=5:or=31'

$env.EDITOR = 'code'

def home_abbrev [] {
    let curr_path = $env.PWD
    $curr_path | str replace $nu.home-path '~'
}

# $env.PROMPT_COMMAND = { $"(home_abbrev)" | color apply yellow }
$env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
# $env.PROMPT_COMMAND_RIGHT = { || } # no right prompt
$env.PROMPT_INDICATOR_VI_NORMAL = '> '
$env.PROMPT_INDICATOR_VI_INSERT = '> '
# $env.PROMPT_INDICATOR_VI_INSERT = '〉' | color apply red
# $env.PROMPT_MULTILINE_INDICATOR = '⮞ ' | color apply red

# $env.config.buffer_editor = 'nvim'
$env.config.buffer_editor = 'code'
$env.config.edit_mode = 'vi'
$env.config.history.isolation = true
$env.config.show_banner = false
# $env.config.show_banner = 'short'
$env.config.float_precision = 3
# $env.config.hooks.env_change = { HOMEPATH: [{|| print banner}] }
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"

# $env.config.color_config = {
#     shape_string: green
#     float: white
#     list: white
#     shape_block: blue_bold
#     shape_flag: blue_bold
#     shape_pipe: purple_bold
#     shape_raw_string: light_purple
#     shape_redirection: purple_bold
#     shape_signature: green_bold
#     glob: cyan_bold
#     search_result: {bg: red, fg: white}
#     shape_list: cyan_bold
#     shape_range: yellow_bold
#     shape_table: blue_bold
#     shape_datetime: cyan_bold
#     block: white
#     shape_nothing: light_cyan
#     row_index: green_bold
#     separator: white
#     shape_float: purple_bold
#     leading_trailing_space_bg: {attr: n}
#     hints: dark_gray
#     shape_matching_brackets: {attr: u}
#     datetime: purple
#     shape_glob_interpolation: cyan_bold
#     shape_custom: green
#     cell-path: white
#     header: green_bold
#     shape_variable: purple
#     range: white
#     shape_vardecl: purple
#     shape_externalarg: green_bold
#     shape_external: cyan
#     string: white
#     empty: blue
#     shape_binary: purple_bold
#     shape_external_resolved: light_yellow_bold
#     filesize: cyan
#     shape_record: cyan_bold
#     duration: white
#     shape_directory: cyan
#     closure: green_bold
#     shape_string_interpolation: cyan_bold
#     shape_int: purple_bold
#     shape_internalcall: cyan_bold
#     shape_keyword: cyan_bold
#     shape_garbage: {fg: white, bg: red, attr: b}
#     shape_closure: green_bold
#     nothing: white
#     shape_match_pattern: green
#     shape_globpattern: cyan_bold
#     bool: light_cyan
#     int: white
#     shape_operator: yellow
#     shape_literal: blue
#     binary: white
#     shape_bool: light_cyan
#     shape_filepath: cyan
#     record: white
# }

# green --> yellow
# yellow --> green
# cyan --> red
# red --> cyan
# blue --> purple
# purple --> blue

# R, G, B
# M, Y, C

# $env.config.color_config = {
#     shape_string: yellow
#     float: white
#     list: white
#     shape_block: purple_bold
#     shape_flag: purple_bold
#     shape_pipe: blue_bold
#     shape_raw_string: light_blue
#     shape_redirection: blue_bold
#     shape_signature: yellow_bold
#     glob: red_bold
#     search_result: {bg: cyan, fg: white}
#     shape_list: red_bold
#     shape_range: green_bold
#     shape_table: purple_bold
#     shape_datetime: red_bold
#     block: white
#     shape_nothing: light_right
#     row_index: yellow_bold
#     separator: white
#     shape_float: blue_bold
#     leading_trailing_space_bg: {attr: n}
#     hints: dark_gray
#     shape_matching_brackets: {attr: u}
#     datetime: blue
#     shape_glob_interpolation: red_bold
#     shape_custom: yellow
#     cell-path: white
#     header: yellow_bold
#     shape_variable: blue
#     range: white
#     shape_vardecl: blue
#     shape_externalarg: yellow_bold
#     shape_external: red
#     string: white
#     empty: purple
#     shape_binary: blue_bold
#     shape_external_resolved: light_green_bold
#     filesize: red
#     shape_record: red_bold
#     duration: white
#     shape_directory: red
#     closure: yellow_bold
#     shape_string_interpolation: red_bold
#     shape_int: blue_bold
#     shape_internalcall: red_bold
#     shape_keyword: red_bold
#     shape_garbage: {fg: white, bg: red, attr: b}
#     shape_closure: yellow_bold
#     nothing: white
#     shape_match_pattern: yellow
#     shape_globpattern: red_bold
#     bool: light_red
#     int: white
#     shape_operator: green
#     shape_literal: purple
#     binary: white
#     shape_bool: light_red
#     shape_filepath: red
#     record: white
# }

$env.config.plugins.highlight.theme = 'ansi'

# ---------------------------------------------------------------------------- #

# def `config alacritty` [] {
#     cd ([$env.APPDATA 'alacritty'] | path join)
#     code alacritty.toml
# }

def `print config` [] {
    open ~/Projects/nushell-scripts/config.nu | highlight
}

alias scripts = cd ~/Projects/nushell-scripts
alias cat = bat
alias r = nu ./run.nu
alias c = clear

if $nu.is-interactive {
    print banner
}

# ---------------------------------------------------------------------------- #

let keys = open ~/Arrowhead/Files/keys.toml | each key {|k| $k | str upcase }
load-env $keys

source ~/.zoxide.nu
alias cd = z

