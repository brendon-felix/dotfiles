# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

# See https://www.nushell.sh/book/configuration.html

# ---------------------------------- modules --------------------------------- #

use modules/ansi.nu *
use modules/applications.nu *
use modules/banner.nu *
use modules/color.nu *
use modules/container.nu *
use modules/core.nu *
use modules/debug.nu *
use modules/dictionary.nu *
use modules/git.nu *
use modules/list-commands.nu *
use modules/monitor.nu *
use modules/print-utils.nu *
use modules/processes.nu *
use modules/rgb.nu *
use modules/round.nu *
use modules/status.nu *
use modules/system.nu *
use modules/tools.nu *
use modules/splash.nu *
use modules/version.nu *

use bios/bfm.nu *
use bios/siofw.nu *

use completions/cargo-completions.nu *
# use completions/git-completions.nu *
use completions/rg-completions.nu *
use completions/rustup-completions.nu *
use completions/vscode-completions.nu *
use completions/winget-completions.nu *

# ---------------------------- environment config ---------------------------- #

$env.EDITOR = 'code'
$env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
# $env.PROMPT_COMMAND_RIGHT = { || } # no right prompt
$env.PROMPT_INDICATOR_VI_NORMAL = '> '
$env.PROMPT_INDICATOR_VI_INSERT = '> '

$env.VARS_FILE = ('~/vars.toml' | path expand)
# $env.COLORS = {
#     RED: (color query red)
#     GREEN: (color query green)
#     BLUE: (color query blue)
#     YELLOW: (color query yellow)
#     CYAN: (color query cyan)
#     MAGENTA: (color query magenta)
#     BLACK: (color query black)
#     WHITE: (color query white)
#     FOREGROUND: (color query foreground)
#     BACKGROUND: (color query background)
# }

$env.config.buffer_editor = 'nvim'
$env.config.edit_mode = 'vi'
$env.config.history.isolation = true
$env.config.show_banner = false
$env.config.float_precision = 3
$env.config.hooks.env_change = { HOMEPATH: [{|| print banner}] }
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"

# ---------------------------------------------------------------------------- #

# def `config alacritty` [] {
#     cd ([$env.APPDATA 'alacritty'] | path join)
#     code alacritty.toml
# }

alias scripts = cd ~/Projects/nushell-scripts
alias cat = bat
alias r = nu ./run.nu
alias c = clear

# if $nu.is-interactive {
#     banner
# }

# ---------------------------------------------------------------------------- #

export def run [
    --watch(-w): string
] {
    let r = { nu ./run.nu }
    match $watch {
        null => { do $r }
        $w => { watch -g $w ./ $r }
    }
}

export def `watch cargo` [] {
    if not ('Cargo.toml' | path exists) {
        error make -u { msg: "Cargo.toml not found in current directory" }
    }
    if ('run.nu' | path exists) {
        watch -g *.rs ./ { try { nu run.nu } catch { print -n ""}; print (separator) }
    } else {
        watch -g *.rs ./ { try { cargo build --release } catch { print -n "" }; print (separator) }
    }
}

export def `color show` [] {
    $in | each {|e|
        let color_hex = match ($e | describe) {
            "record<r: int, g: int, b: int>" => $e
            "record<h: int, s: float, v: float>" => ($e | rgb from-hsv)
            _ => ($e | into rgb)
        } | rgb get-hex
        let ansi_colors = [
            {fg: $color_hex},
            {bg: $color_hex},
            {fg: $color_hex, attr: 'r'},
            {bg: $color_hex, attr: 'r'},
        ]
        mut container = []
        for ansi_color in $ansi_colors {
            # print $"(ansi -e $ansi_color)(ansi reset)"
            $container = $container | row (my-ellie | color apply $ansi_color)
        }
        $container | container print
    }
}
