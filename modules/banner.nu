# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

# use version.nu 'version check'
use std ellie
use round.nu 'round duration'
use status.nu 'status memory'
use color.nu *
use container.nu [contain box row 'print container']

def startup [] {
    let startup_time = ($nu.startup-time | round duration ms)
    match $startup_time {
        _ if $startup_time == 0sec => null
        _ if $startup_time < 100ms => $"(ansi green)($startup_time)(ansi reset)"
        _ if $startup_time < 500ms => $"(ansi yellow)($startup_time)(ansi reset)"
        _ => $"(ansi red)($startup_time)(ansi reset)"
    }
}

def uptime [] {
    match (sys host).uptime {
        $t if $t < 1day => $"(ansi green)($t | round duration min)(ansi reset)"
        $t if $t < 1wk => $"(ansi yellow)($t | round duration hr)(ansi reset)"
        $t => $"(ansi red)($t | round duration day)(ansi reset)"
    }
}

def header_text [] {
    let curr_version = $"v(version | get version)"
    let shell = $"(ansi green)Nushell ($curr_version)(ansi reset)"
    let username = ($env.USERNAME | str trim) | color purple
    let hostname = (sys host | get hostname) | color purple
    let user = $"($username)@($hostname)"
    let length = [($shell | color length), ($user | color length)] | math max
    let separator = ("" | fill -c '─' -w $length | str join)
    [$shell $separator $user] | contain -x 0
}

def header [] {
    let ellie = ellie | ansi strip | lines | each { |it| $"(ansi green)($it)(ansi reset)" } | contain -x 0 --pad-bottom 1
    $ellie | row -s 2 -a c (header_text) | contain -x 0
}

def info [] {
    let startup = startup
    let uptime = uptime
    let memory = status memory -b
    
    mut info = [
        $"This system has been up for ($uptime)."
        $"($memory.RAM) of memory is in use."
    ]
    if $startup != null {
        $info | prepend $"It took ($startup) to start this shell."
    }
}

export def main [] {
    # header | append (info | contain) | contain -x 0 | box
    header | contain -x 2 | box | append (info | contain | box)
}
