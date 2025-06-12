# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

# use version.nu 'version check'
use std ellie
use round.nu 'round duration'
use status.nu *
use ansi.nu *
use container.nu *

use debug.nu *

def startup []: nothing -> string {
    let startup_time = ($nu.startup-time | round duration ms)
    match $startup_time {
        $t if $t == 0sec => null
        $t if $t < 100ms => ($t | color green)
        $t if $t < 500ms => ($t | color red)
        $t => ($t | color red)
    }
}

def uptime []: nothing -> string {
    match (sys host).uptime {
        $t if $t < 1day => ($t | round duration min | color green)
        $t if $t < 1wk => ($t | round duration hr | color yellow)
        $t => ($t | round duration day | color red)
    }
}

def header_text []: nothing -> list<string> {
    let curr_version = $"v(version | get version)"
    let shell = $"Nushell ($curr_version)" | color green

    let username = $env.USERNAME | color light_purple
    let hostname = sys host | get hostname | color light_purple
    let user = $"($username)@($hostname)"

    let width = [($shell | strip length), ($user | strip length)] | math max
    let separator = "" | fill -c '─' -w $width
    [$shell $separator $user] | contain -p tight
}

def header []: nothing -> list<string> {
    my-ellie | row -s 2 -a c (header_text) | contain -p tight
}

def info [
    type?: string = "keyval" # the type of info to display: keyval, english, record
    --bar(-b)
]: nothing -> list<string> {
    let startup = startup
    let uptime = uptime
    let memory = status memory --no-bar=(not $bar)
    
    # mut info = match [
    #     $"This system has been up for ($uptime)."
    #     $"($memory.RAM) of memory is in use."
    # ]

    let info = match $type {
        keyval => {
            [
                $"(ansi light_blue)startup:(ansi reset) ($startup)"
                $"(ansi light_blue)uptime:(ansi reset)  ($uptime)"
                $"(ansi light_blue)memory:(ansi reset)  ($memory.RAM)"
            ]
        }
        english => {
            [
                $"It took ($startup) to start this shell."
                $"This system has been up for ($uptime)."
                $"($memory.RAM) of memory is in use."
            ]
        }
        record => {
            {
                startup: $startup
                uptime: $uptime
                memory: $memory.RAM
            }
        }
        _ => {
            error make {
                msg: "invalid info type"
                label: {
                    text: "type not recognized"
                    span: (metadata $type).span
                }
                help: "Use `banner --help` to see available types."
            }
        }
    }
    $info
}

# container-based ellie
export def my-ellie []: nothing -> list<string> {
    ellie | ansi strip | lines | color green | contain -p tight --pad-bottom 1
}

export def `print info` [
    type?: string = "keyval" # the type of info to print: keyval, english, record`
    --bar(-b)
] {
    info $type --bar=$bar | contain -p t | container print
}

export def `print banner` [
    type? = basic # the type of banner to print: ellie, header, info, row, stack
] {
    main $type | contain -p t | container print
}

# creates a container-based banner for printing
export def main [
    type? = basic # the type of banner to create: ellie, header, info, row, stack
]: nothing -> list<string> {
    match $type {
        ellie => (my-ellie | box)
        header => (header | contain -x 2 | box)
        info => (info | contain -p "comfy" | box)
        row => (header | contain -x 2 | box | row (info | contain -p "comfy" | box))
        stack => (header | contain -x 2 | box | append (info | contain | box) | contain -a l -p tight)
        # _ => (header | contain --pad-left 3 | append (info | contain -x 2 --pad-bottom 1) | contain -a l -p tight | box)
        basic => (header | append $"RAM: (status memory | get RAM)"| contain -a c | box)

        _ => {
            error make {
                msg: "invalid banner type"
                label: {
                    text: "type not recognized"
                    span: (metadata $type).span
                }
                help: "Use `banner --help` to see available types."
            }
        }
    }
    # header | append $"("RAM" | color blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | color blue): ($status)"}) | contain -a c | box
}
