# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

source aliases.nu
source zoxide.nu

const PRIVATE_CONFIG = '~/Vault/nushell/private.nu'
source (
    if ($PRIVATE_CONFIG | path exists) {
        $PRIVATE_CONFIG
    } else {
        # warn $"($PRIVATE_CONFIG) not found"
        null
    }
)

source (if $nu.os-info.name == macos { 'macos.nu' })
source (if $nu.os-info.name == windows { 'windows.nu' })

use std repeat
use modules *
use completions *
use helpers.nu *
use hp *

# ------------------------------ env variables ------------------------------- #

$env.EDITOR = find program [zed code nvim hx vim vi nano edit]

$env.PROMPT_COMMAND = { prompt-left }
$env.PROMPT_COMMAND_RIGHT = { prompt-right }
$env.PROMPT_INDICATOR_VI_NORMAL = { prompt-indicator }
$env.PROMPT_INDICATOR_VI_INSERT = { prompt-indicator }
$env.PROMPT_MULTILINE_INDICATOR = ''

$env.BIOS_CONFIGS = try { open ~/.bios-configs.toml } catch { null }
$env.FIRST_PROMPT = true
$env.PROCEDURE_LEVEL = 0
$env.PROCEDURE_DEBUG = false
$env.STOPWATCHES = []
$env.STOPWATCH_ID = 0

let ls_colors = load ls-colors
if $ls_colors != null { $env.LS_COLORS = $ls_colors }

let keys = load keys ~/Vault/keys.toml
if $keys != null { load-env $keys }

let paths = [
    ~/.local/bin/
    ~/.cargo/bin/
    ~/neovim/build/bin/
    ~/Library/Python/3.9/bin/
    ~/Library/Android/sdk/platform-tools/
    ~/Projects/subroutine/target/release/
    ~/Projects/bar/target/release/
    ~/Projects/hey/target/release/
    ~/Projects/spewcap/target/release/
    ~/Projects/regiman/target/release/
    /usr/local/bin/
    /opt/homebrew/bin/
    /opt/homebrew/opt/libpq/bin/
    /Applications/Android Studio.app/Contents/jbr/Contents/Home/bin
] | each { path expand } | where { path exists }

$env.PATH = $env.PATH ++ $paths

# ---------------------------------- config ---------------------------------- #

$env.config.buffer_editor = find program [nvim hx vim vi nano edit]
$env.config.edit_mode = 'vi'
$env.config.float_precision = 3
$env.config.table.index_mode = 'auto'
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"
$env.config.display_errors.termination_signal = false
$env.config.completions.algorithm = 'fuzzy'
$env.config.show_banner = false # true, false, or 'short'

$env.config.hooks.pre_prompt = pre-prompt
$env.config.hooks.pre_execution = pre-execution

$env.config.plugins.highlight.custom_themes = '~/Projects/dotfiles/bat/themes'
$env.config.plugins.highlight.theme = 'Fleetish'

# ---------------------------------------------------------------------------- #

print banner header
