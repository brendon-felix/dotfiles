# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

source aliases.nu
source zoxide.nu

# ------------------------------ env variables ------------------------------- #

# $env.VARS_FILE = ('~/.nu-vars.toml' | path expand)
$env.PROCEDURE_LEVEL = 0
$env.PROCEDURE_DEBUG = false
# $env.BIOS_PROJECTS = open ('~/Projects/nushell-scripts/bios/projects.json' | path expand)
# $env.CURR_PROJECT = $env.BIOS_PROJECTS | find -n 'Springs' | first
$env.EDITOR = 'nvim'
# $env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
$env.PROMPT_COMMAND_RIGHT = { || }
$env.PROMPT_INDICATOR_VI_NORMAL = '> '
$env.PROMPT_INDICATOR_VI_INSERT = '> '

# -------------------------------- env config -------------------------------- #

$env.config.buffer_editor = $env.EDITOR
$env.config.edit_mode = 'vi'
$env.config.history.isolation = true
$env.config.show_banner = false
# $env.config.show_banner = 'short'
$env.config.float_precision = 3
# $env.config.hooks.env_change = { HOMEPATH: [{|| print banner}] }
# $env.config.hooks.env_change = { HOMEPATH: [{|| use ~/Projects/dotfiles/nushell/modules *}] }
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"
$env.config.plugins.highlight.theme = 'ansi'


def show [file] {
    open -r $file | highlight
}

