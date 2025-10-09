# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

use std [repeat ellie]

use container.nu ['contain' 'container print' 'row' 'box']
use status.nu ['status startup' 'status uptime' 'status memory']
use paint.nu main

def header_text []: nothing -> list<string> {
    # let curr_version = match (version check) {
    #     $c if $c.current => $"(ansi green)v($env.NU_VERSION)(ansi reset)"
    #     $c => $"(ansi yellow)v($env.NU_VERSION)(ansi reset)"
    # }
    # let shell = $"(ansi green)Nushell(ansi reset) " + $curr_version
    let shell = $"Nushell v($env.NU_VERSION)" | paint green
    let username = if $nu.os-info.name == windows { $env.USERNAME } else { $env.USER }
        | paint light_purple
    let hostname = sys host | get hostname | str replace '.local' '' | paint light_purple
    let user = $"($username)@($hostname)"
    let width = [
        ($shell | ansi strip | str length -g)
        ($user | ansi strip | str length -g)
    ] | math max
    let separator = "" | fill -c '─' -w $width
    let max_length = [$shell $separator $user] | ansi strip | str length -g | math max
    [$shell $separator $user] | contain -p t -a l
}

def my-ellie []: nothing -> list<string> {
    ellie | ansi strip | contain -x 2 --pad-bottom 1
}

def header []: nothing -> list<string> {
    let header_text = header_text | contain -p t --pad-top 1 --pad-right 2
    my-ellie | each { paint green } | row -s 0 -a c $header_text | contain -p tight
}

def "nu-complete banner-type" [] {
    ["ellie" "user" "header" "memory"]
}

# ---------------------------------------------------------------------------- #

# Creates a custom container-based banner
def banner [
    type: string@"nu-complete banner-type"
]: nothing -> list<string> {
    match $type {
        ellie => (my-ellie | paint green | box)
        user => (header_text | contain -p c | box)
        header => (header | box)
        memory => (header | append $"RAM: (status memory -b)" | contain -a c | box)
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
}

# Prints a custom container-based banner
export def `print banner` [
    type?: string@"nu-complete banner-type" = 'memory'
] {
    banner $type | contain -p t | container print
}
