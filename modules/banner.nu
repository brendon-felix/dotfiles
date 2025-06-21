# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

# use version.nu 'version check'
use std ellie
use round.nu 'round duration'
use status.nu *
use ansi.nu 'strip length'
use color.nu 'color apply'
use container.nu *
use version.nu 'version check'

use debug.nu *

def startup []: nothing -> string {
    let startup_time = ($nu.startup-time | round duration ms)
    match $startup_time {
        $t if $t == 0sec => null
        $t if $t < 100ms => ($t | into string | color apply green)
        $t if $t < 500ms => ($t | into string | color apply yellow)
        $t => ($t | into string | color apply red)
    }
}

def uptime []: nothing -> string {
    match (sys host).uptime {
        $t if $t < 1day => ($t | round duration min | into string | color apply green)
        $t if $t < 1wk => ($t | round duration hr | into string | color apply yellow)
        $t => ($t | round duration day | into string | color apply red)
    }
}

def header_text []: nothing -> list<string> {
    let curr_version = match (version check) {
        $c if $c.current => ($"v($env.NU_VERSION)" | color apply green)
        $c => ($"v($env.NU_VERSION)" | color apply yellow)
    }
    # let curr_version = $env.NU_VERSION | color apply green
    let shell = ("Nushell " | color apply green) + $curr_version
    let username = $env.USERNAME | color apply light_purple
    let hostname = sys host | get hostname | color apply light_purple
    let user = $"($username)@($hostname)"

    let width = [($shell | strip length), ($user | strip length)] | math max
    let separator = "" | fill -c '─' -w $width
    [$shell $separator $user] | contain -p tight
}

def info [
    type?: string = "keyval" # the type of info to display: keyval, english, record
    --bar(-b)
]: nothing -> list<string> {
    let startup = startup
    let uptime = uptime
    let memory = status memory --no-bar=(not $bar)
    let info = match $type {
        keyval => {
            [
                $"(ansi light_blue)startup:(ansi reset) ($startup)"
                $"(ansi light_blue)uptime:(ansi reset) ($uptime)"
                $"(ansi light_blue)memory:(ansi reset) ($memory.RAM)"
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
    ellie | ansi strip | contain -x 2 --pad-bottom 1
}

def header []: nothing -> list<string> {
    my-ellie | color apply green | row -s 0 -a c (header_text | contain -p t --pad-top 1 --pad-right 2) | contain -p tight
}

def tight_header []: nothing -> list<string> {
    my-ellie | row -s 2 -a c (header_text) | contain -p tight
}

export alias `builtin banner` = banner

# Prints a custom banner
export def `print banner` [
    type? = memory # the type of banner to print: ellie, header, info, row, stack
] {
    main $type | contain -p t | container print
}

# Creates a custom container-based banner
export def main [
    type?: string = memory # the type of banner to create: # ellie, user, header, info, info_english, info_record, row, stack, row_english, stack_english, memory, mem_disks, test
]: nothing -> list<string> {
    match $type {
        ellie => (my-ellie | color apply green | box)
        user => (header_text | contain -p c | box)
        header => (header | box)
        info => (info | contain -p "comfy" | box)
        info_english => (info english | contain -p "comfy" | box)
        info_record => (info record)
        row => (header | box | row -a b (info | contain | box))
        stack => (header | box | append (info | contain | box) | contain -p tight)
        row_english => (header | box | row -a b (info english | contain | box))
        stack_english => (header | box | append (info english | contain | box) | contain -p tight)
        memory => (header | append $"RAM: (status memory | get RAM)"| contain -a c | box)
        mem_disks => (header | append $"("RAM" | color apply blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | color apply blue): ($status)"}) | contain -a l | box)
        test => (header | box | row -s 2 -a c (info english))
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
    # header | append $"("RAM" | color apply blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | color apply blue): ($status)"}) | contain -a c | box
}
