# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

# See https://www.nushell.sh/book/configuration.html

# ---------------------------------- modules --------------------------------- #

use modules *
use completions *
use bios *

source ('~/.sys-commands.nu' | path expand)

# ------------------------------ env variables ------------------------------- #

$env.VARS_FILE = ('~/.nu-vars.toml' | path expand)

$env.PROCEDURE_LEVEL = 0
$env.PROCEDURE_DEBUG = true

$env.BIOS_PROJECTS = open ('~/Projects/nushell-scripts/bios/projects.json' | path expand)
$env.CURR_PROJECT = $env.BIOS_PROJECTS | find -n 'Springs' | first

$env.EDITOR = 'nvim'

$env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
$env.PROMPT_INDICATOR_VI_NORMAL = '> '
$env.PROMPT_INDICATOR_VI_INSERT = '> '

# load API key environment variables
if ('~/Arrowhead/Files/keys.toml' | path exists) {
    load-env (open ~/Arrowhead/Files/keys.toml | each key {|k| $k | str upcase })
}

# -------------------------------- env config -------------------------------- #

$env.config.buffer_editor = $env.EDITOR
$env.config.edit_mode = 'vi'

$env.config.history.isolation = true

$env.config.show_banner = false
# $env.config.show_banner = 'short'

$env.config.float_precision = 3

# $env.config.hooks.env_change = { HOMEPATH: [{|| print banner}] }

$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"

$env.config.plugins.highlight.theme = 'ansi'

# --------------------------------- aliases ---------------------------------- #

alias r = nu ./run.nu

source ~/.zoxide.nu
alias cd = z

# ---------------------------------- banner ---------------------------------- #

if $nu.is-interactive {
    match (sys host | get hostname) {
        'kepler' => (print banner header)
        _ => (print banner memory)
    }
}

