# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

source aliases.nu
source zoxide.nu
source ~/.sys-commands.nu
use modules *
use bios *
use completions *
use config-helpers.nu *
use macos.nu *

# ------------------------------ env variables ------------------------------- #

$env.EDITOR = 'zed'

$env.PROMPT_COMMAND = { generate prompt-left }
$env.PROMPT_COMMAND_RIGHT = { generate prompt-right }
$env.PROMPT_INDICATOR_VI_NORMAL = { generate prompt-indicator }
$env.PROMPT_INDICATOR_VI_INSERT = { generate prompt-indicator }
$env.PROMPT_MULTILINE_INDICATOR = ''

$env.BIOS_CONFIGS = try { open ~/.bios-configs.toml } catch { null }
$env.FIRST_PROMPT = true
$env.PROCEDURE_LEVEL = 0
$env.PROCEDURE_DEBUG = false

match (ls-colors) {
    null => {}
    $ls_colors => { $env.LS_COLORS = $ls_colors }
}

match (get-keys ~/Arrowhead/Files/keys.toml) {
    null => {}
    $keys => { load-env $keys }
}

$env.PATH = $env.PATH | append ([
    '~/Projects/bar/target/release/'
    '~/Projects/hey/target/release/'
    '~/Projects/spewcap/target/release/'
    '~/Projects/size-converter/target/release/'
    '/usr/local/bin/'
    '/opt/homebrew/bin/'
    '~/Library/Python/3.9/bin/'
    '~/.cargo/bin/'
    '~/neovim/build/bin/'
] | each { path expand } | where { path exists })

# ---------------------------------- config ---------------------------------- #

$env.config.buffer_editor = 'nvim'
$env.config.edit_mode = 'vi'
$env.config.float_precision = 3
$env.config.table.index_mode = 'auto'
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"
$env.config.display_errors.termination_signal = false

# $env.config.show_banner = 'short'
$env.config.show_banner = false

$env.config.plugins.highlight.theme = 'ansi'

$env.config.hooks.pre_prompt = [
    { $env.CMD_EXECUTION_TIME = try { (date now) - $env.PRE_EXECUTION_TIME } catch { null } }
    { job spawn {gstat | job send 0 --tag 42 }}
]
$env.config.hooks.pre_execution = [
    { if $env.FIRST_PROMPT { $env.FIRST_PROMPT = false }}
    { $env.PRE_EXECUTION_TIME = date now }
]

# ---------------------------------------------------------------------------- #

print banner header
