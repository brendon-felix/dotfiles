
# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

use std ellie
use container.nu ['contain' 'container print' 'row' 'box']
use color.nu 'ansi apply'
use status.nu ['status memory' 'status disks']
use round.nu 'round duration'

def startup []: nothing -> string {
    let startup_time = ($nu.startup-time | round duration ms)
    match $startup_time {
        $t if $t == 0sec => null
        $t if $t < 100ms => ($t | into string | ansi apply green)
        $t if $t < 500ms => ($t | into string | ansi apply yellow)
        $t => ($t | into string | ansi apply red)
    }
}

def uptime []: nothing -> string {
    match (sys host).uptime {
        $t if $t < 1day => ($t | round duration min | into string | ansi apply green)
        $t if $t < 1wk => ($t | round duration hr | into string | ansi apply yellow)
        $t => ($t | round duration day | into string | ansi apply red)
    }
}

def header_text []: nothing -> list<string> {
    let curr_version = match (version check) {
        $c if $c.current => ($"v($env.NU_VERSION)" | ansi apply green)
        $c => ($"v($env.NU_VERSION)" | ansi apply yellow)
    }
    # let curr_version = $env.NU_VERSION | ansi apply green
    let shell = ("Nushell " | ansi apply green) + $curr_version
    let username = $env.USERNAME | ansi apply light_purple
    let hostname = sys host | get hostname | ansi apply light_purple
    let user = $"($username)@($hostname)"

    let width = [($shell | strip length), ($user | strip length)] | math max
    let separator = "" | fill -c '─' -w $width
    [$shell $separator $user] | contain -p tight
}

def info_text [
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
    my-ellie | ansi apply green | row -s 0 -a c (header_text | contain -p t --pad-top 1 --pad-right 2) | contain -p tight
}

def tight_header []: nothing -> list<string> {
    my-ellie | row -s 2 -a c (header_text) | contain -p tight
}

export alias `builtin banner` = banner

# Prints a custom banner
export def `print banner` [
    type? = memory # the type of banner to print: ellie, header, info, row, stack
] {
    banner $type | contain -p t | container print
}

export def `print info` [
    type?: string = record # the type of info to print: keyval, english, record
    --bar(-b)
] {
    if $type == "record" {
        print (info_text --bar=$bar record)
    } else {
        info_text $type --bar=$bar | contain -p c | box | container print
    }
}

export def info [--bar] {
    info_text --bar=$bar record
}

# Creates a custom container-based banner
def banner [
    type?: string = memory # the type of banner to create: # ellie, user, header, info, info_english, info_record, row, stack, row_english, stack_english, memory, mem_disks, test
]: nothing -> list<string> {
    match $type {
        ellie => (my-ellie | ansi apply green | box)
        user => (header_text | contain -p c | box)
        header => (header | box)
        info => (info_text | contain -p "comfy" | box)
        info_english => (info_text english | contain -p "comfy" | box)
        info_record => (info_text record)
        row => (header | box | row -a b (info_text | contain | box))
        stack => (header | box | append (info_text | contain | box) | contain -p tight)
        row_english => (header | box | row -a b (info_text english | contain | box))
        stack_english => (header | box | append (info_text english | contain | box) | contain -p tight)
        memory => (header | append $"RAM: (status memory | get RAM)"| contain -a c | box)
        mem_disks => (header | append $"("RAM" | ansi apply blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | ansi apply blue): ($status)"}) | contain -a l | box)
        test => (header | box | row -s 2 -a c (info_text english))
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
    # header | append $"("RAM" | ansi apply blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | ansi apply blue): ($status)"}) | contain -a c | box
}

