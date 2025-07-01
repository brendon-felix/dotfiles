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

$env.EDITOR = 'code'
$env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
# $env.PROMPT_COMMAND_RIGHT = { || } # no right prompt
$env.PROMPT_INDICATOR_VI_NORMAL = '> '
$env.PROMPT_INDICATOR_VI_INSERT = '> '

# $env.config.buffer_editor = 'nvim'
$env.config.buffer_editor = 'code'
$env.config.edit_mode = 'vi'
$env.config.history.isolation = true
# $env.config.show_banner = false
$env.config.show_banner = 'short'
$env.config.float_precision = 3
# $env.config.hooks.env_change = { HOMEPATH: [{|| print banner}] }
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"

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



