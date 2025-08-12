
# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

export def "round duration" [unit?]: duration -> duration {
    each { |e|
        let unit_time = match $unit {
            ns => 1ns,
            us => 1us,
            ms => 1ms,
            sec => 1sec,
            min => 1min,
            hr => 1hr,
            day => 1day,
            wk => 1wk,
            null => {
                match $e {
                    _ if ($e < 1ms) => 1ns,
                    _ if ($e < 1sec) => 1us,
                    _ if ($e < 1min) => 1ms,
                    _ if ($e < 1hr) => 1sec,
                    _ if ($e < 1day) => 1min,
                    _ if ($e < 1wk) => 1hr,
                    _ => 1day
                }
            }
            _ => {
                throw "Invalid unit: $unit"
            }
        }
        let rounded_ns = ($e / $unit_time | math round) * $unit_time
        $rounded_ns | into duration
    }
}

# ---------------------------------------------------------------------------- #

const header = r#'
╭────────────────────────────────╮
│       __  ,                    │
│   .--()°'.'  Nushell v0.105.1  │
│  '|, . ,'    ────────────────  │
│   !_-(_\     brend@pluto       │
│                                │
╰────────────────────────────────╯
'#

def round_sec [precision]: duration -> float {
    let ns_int = $in | into int
    let sec_float = $ns_int / 1e9
    let rounded = $sec_float | math round -p $precision
    $rounded
}

def startup []: nothing -> string {
    let startup_time = ($nu.startup-time | round duration ms)
    # let startup_time = $nu.startup-time
    let m = if $env.MODULES_LOADED { [1sec, 2sec] } else { [100ms, 250ms] }
    match $startup_time {
        $t if $t == 0sec => null
        $t if $t < $m.0 => $"(ansi green)($t)(ansi reset)"
        $t if $t < $m.1 => $"(ansi yellow)($t)(ansi reset)"
        $t => $"(ansi red)($t)(ansi reset)"
    }
}

def uptime []: nothing -> string {
    match (sys host).uptime {
        $t if $t < 1day => $"(ansi green)($t | round duration min)(ansi reset)"
        $t if $t < 1wk => $"(ansi yellow)($t | round duration hr)(ansi reset)"
        $t => $"(ansi red)($t | round duration day)(ansi reset)"
    }
}

def memory [] {
    let memory = sys mem
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    mut memory_status = $"($memory.used) \(($percent_used)%\)"
    # let memory_bar = ~/Projects/bar/target/release/bar.exe -l 12 $proportion_used
    # $memory_status = $"($memory_bar) ($memory_status)"
    match $proportion_used {
        _ if $proportion_used < 0.6 => $"(ansi green)($memory_status)(ansi reset)"
        _ if $proportion_used < 0.8 => $"(ansi yellow)($memory_status)(ansi reset)"
        _ => $"(ansi red)($memory_status)(ansi reset)"
    }
}

# def header_text []: nothing -> list<string> {
#     let curr_version = match (version check) {
#         $c if $c.current => $"(ansi green)v($env.NU_VERSION)(ansi reset)"
#         $c => $"(ansi yellow)v($env.NU_VERSION)(ansi reset)"
#     }
#     let shell = $"(ansi green)Nushell(ansi reset) " + $curr_version
#     let username = $"(ansi light_purple)($env.USERNAME)(ansi reset)"
#     let hostname = $"(ansi light_purple)(sys host | get hostname)(ansi reset)"
#     let user = $"($username)@($hostname)"
#
#     let width = [($shell | ansi strip | str length -g), ($user | ansi strip | str length -g)] | math max
#     let separator = "" | fill -c '─' -w $width
#     let max_length = [$shell $separator $user] | ansi strip | str length -g | math max
#     [$shell $separator $user] | each {|e|
#         $e | fill -w $max_length
#     }
# }

export def info [
    type?: string = "keyval" # the type of info to display: keyval, english, record
    --color(-c): string = "light_blue" # the color to use for the labels
] {
    let startup = startup
    let uptime = uptime
    let memory = memory
    let info = match $type {
        keyval => {
            # [
            #     $"(ansi light_blue)startup:(ansi reset) ($startup)"
            #     $"(ansi light_blue)uptime:(ansi reset) ($uptime)"
            #     $"(ansi light_blue)memory:(ansi reset) ($memory)"
            # ]
            [
                $"(ansi $color)startup:(ansi reset) ($startup)"
                $"(ansi $color)uptime:(ansi reset) ($uptime)"
                $"(ansi $color)memory:(ansi reset) ($memory)"
            ]
        }
        icons => {
            [
                $"(ansi $color)(char -u f520) (ansi reset) ($startup)"
                $"(ansi $color)(char -u f43a) (ansi reset) ($uptime)"
                $"(ansi $color)(char -u efc5) (ansi reset) ($memory)"
            ]
        }
        english => {
            [
                $"It took ($startup) to start this shell."
                $"This system has been up for ($uptime)."
                $"($memory) of memory is in use."
            ]
        }
        record => {
            {
                startup: $startup
                uptime: $uptime
                memory: $memory
            }
        }
        _ => {
            error make {
                msg: "invalid info type"
                label: {
                    text: "type not recognized"
                    span: (metadata $type).span
                }
            }
        }
    }
    $info
}

# # container-based ellie
# export def my-ellie []: nothing -> list<string> {
#     let ellie = r#'
#        __  ,  
#    .--()°'.'  
#   '|, . ,'    
#    !_-(_\     
#
# '#
# }
#
# def header []: nothing -> list<string> {
#     my-ellie | ansi apply green | row -s 0 -a c (header_text | contain -p t --pad-top 1 --pad-right 2) | contain -p tight
# }
#
# def tight_header []: nothing -> list<string> {
#     my-ellie | row -s 2 -a c (header_text) | contain -p tight
# }
#
# export alias `builtin banner` = banner
#
# # Prints a custom banner
# export def `print banner` [
#     type? = memory # the type of banner to print: ellie, header, info, row, stack
# ] {
#     banner $type | contain -p t | container print
# }
#
# export def `print info` [
#     type?: string = record # the type of info to print: keyval, english, record
#     --bar(-b)
# ] {
#     if $type == "record" {
#         print (info_text --bar=$bar record)
#     } else {
#         info_text $type --bar=$bar | contain -p c | box | container print
#     }
# }

# # Creates a custom container-based banner
# def banner [
#     type?: string = memory # the type of banner to create: # ellie, user, header, info, info_english, info_record, row, stack, row_english, stack_english, memory, mem_disks, test
# ]: nothing -> list<string> {
#     match $type {
#         ellie => (my-ellie | ansi apply green | box)
#         user => (header_text | contain -p c | box)
#         header => (header | box)
#         info => (info_text | contain -p "comfy" | box)
#         info_english => (info_text english | contain -p "comfy" | box)
#         info_record => (info_text record)
#         row => (header | box | row -a b (info_text | contain | box))
#         stack => (header | box | append (info_text | contain | box) | contain -p tight)
#         row_english => (header | box | row -a b (info_text english | contain | box))
#         stack_english => (header | box | append (info_text english | contain | box) | contain -p tight)
#         memory => (header | append $"RAM: (status memory | get RAM)"| contain -a c | box)
#         mem_disks => (header | append $"("RAM" | ansi apply blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | ansi apply blue): ($status)"}) | contain -a l | box)
#         test => (header | box | row -s 2 -a c (info_text english))
#         _ => {
#             error make {
#                 msg: "invalid banner type"
#                 label: {
#                     text: "type not recognized"
#                     span: (metadata $type).span
#                 }
#                 help: "Use `banner --help` to see available types."
#             }
#         }
#     }
#     # header | append $"("RAM" | ansi apply blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | ansi apply blue): ($status)"}) | contain -a c | box
# }
#
