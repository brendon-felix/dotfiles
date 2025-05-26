# -------------------------------------------------------------------------- #
#                                  config.nu                                 #
# -------------------------------------------------------------------------- #

# See https://www.nushell.sh/book/configuration.html

# --------------------------- environment config --------------------------- #

$env.EDITOR = 'code'
$env.config.buffer_editor = 'code'

# $env.PROMPT_COMMAND = { || pwd }

$env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
# $env.PROMPT_COMMAND_RIGHT = { || mem_used_str }
# $env.PROMPT_COMMAND_RIGHT = { || } # no right prompt

# $env.PROMPT_INDICATOR = " "

$env.config.history.isolation = true

$env.config.show_banner = "short"

$env.config.completions.algorithm = "fuzzy"

# $env.config.bracketed_paste = true

$env.config.float_precision = 3

$env.config.cursor_shape.emacs = "line"

$env.config.color_config


# ---------------------------- built-in aliases ---------------------------- #

alias ll = ls -l
alias r = nu ./run.nu
alias cr = cargo run
alias c = clear

# ------------------------------ git commands ------------------------------ #

alias gsw = git switch
alias gbr = git branch
alias grh = git reset --hard
alias gcl = git clean -fd
def grst [] { git reset --hard; git clean -fd }
def gpsh [] { git add .; git commit -m "quick update"; git push }


# ------------------------------ tool aliases ------------------------------ #

alias bfm = nu ~/Projects/nushell-scripts/bfm.nu
alias siofw = nu ~/Projects/nushell-scripts/siofw.nu
# alias mfit = nu ~/Projects/nushell-scripts/mfit.nu

alias spewcap = ~/Projects/spewcap2/target/release/spewcap2.exe
alias size = ~/Projects/size-converter/target/release/size-converter.exe
alias chat = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/api_key.txt -p ~/system_prompt.txt

# ------------------------------ misc commands ----------------------------- #

def "config nu" [] {
    code ~/Projects/nushell-scripts/config.nu
}

def srev [] {
	$in | sort-by modified | reverse
}

def mem_used_str [] {
    let memory = (sys mem)
    let mem_used = $memory.used / $memory.total
    let mem_used_bar = (asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $mem_used)
    let memory_used_display_uncolored = $"($mem_used_bar) ($memory.used) \(($mem_used * 100 | math round --precision 0 )%\)"
    match $mem_used {
        _ if $mem_used < 0.6 => $"(ansi green)($memory_used_display_uncolored)(ansi reset)"
        _ if $mem_used < 0.8 => $"(ansi yellow)($memory_used_display_uncolored)(ansi reset)"
        _ => $"(ansi red)($memory_used_display_uncolored)(ansi reset)"
    }
}

source ~/Projects/nushell-scripts/round.nu

# ------------------------ machine specific commands ----------------------- #

source ~/Projects/nushell-scripts/commands.nu

# --------------------------- banner/screenfetch --------------------------- #

if $nu.is-interactive {
	# requires asciibar: `cargo install asciibar`
	# source ~/banner.nu
	nu ~/Projects/nushell-scripts/banner.nu
    print ""
}