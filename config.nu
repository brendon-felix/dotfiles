# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

# See https://www.nushell.sh/book/configuration.html

use round.nu *
use banner.nu *
use system.nu *
source winget.nu

source misc.nu
source math.nu
source commands.nu
source applications.nu

# ---------------------------- environment config ---------------------------- #

$env.EDITOR = 'code'
$env.config.buffer_editor = 'code'

# $env.PROMPT_COMMAND = { || pwd }

$env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
# $env.PROMPT_COMMAND_RIGHT = { || mem_used_str }
# $env.PROMPT_COMMAND_RIGHT = { || } # no right prompt

# $env.PROMPT_INDICATOR = " "

$env.config.history.isolation = true

$env.config.show_banner = false

$env.config.completions.algorithm = "fuzzy"

# $env.config.bracketed_paste = true

$env.config.float_precision = 3

$env.config.filesize = {
    unit: "metric",
    show_unit: true,
    precision: 1,
}

$env.config.cursor_shape.emacs = "line"

$env.config.color_config

$env.config.hooks = {
    env_change: { HOMEPATH: [{|| banner}] }
}

# ---------------------------------------------------------------------------- #

alias ll = ls -l
alias r = nu ./run.nu
alias cr = cargo run
alias c = clear

alias du = dust

# ------------------------------------ git ----------------------------------- #

alias gsw = git switch
alias gbr = git branch
alias grh = git reset --hard
alias gcl = git clean -fd
def grst [] { git reset --hard; git clean -fd }
def gpsh [] { git add .; git commit -m "quick update"; git push }

# ---------------------------------- scripts --------------------------------- #

alias bfm = nu ~/Projects/nushell-scripts/bfm.nu
alias siofw = nu ~/Projects/nushell-scripts/siofw.nu
# alias mfit = nu ~/Projects/nushell-scripts/mfit.nu

alias spewcap = ~/Projects/spewcap2/target/release/spewcap2.exe
alias size = ~/Projects/size-converter/target/release/size-converter.exe
alias chat = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/api_key.txt -p ~/system_prompt.txt

# ---------------------------------- banner ---------------------------------- #

if $nu.is-interactive {
    # let nushell_text = [
    # `                 _          _ _ `,
    # ` _ __  _   _ ___| |__   ___| | |`,
    # `| '_ \| | | / __| '_ \ / _ \ | |`,
    # `| | | | |_| \__ \ | | |  __/ | |`,
    # `|_| |_|\__,_|___/_| |_|\___|_|_|`,
    # `                                `,
    # ]
    # let nushell_text = $nushell_text | each { |it| $"(ansi green)($it)(ansi reset)" }

    # banner
    
    # for line in $nushell_text {
    #     print $" ($line)"
    # }
}
