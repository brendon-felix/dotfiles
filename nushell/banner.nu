
# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

use std [repeat ellie]

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

export def contain [
    --pad(-p): string = normal      # padding style: normal (n), comfy (c), tight (t)
    --pad-x(-x): int = 0,           # horizontal padding
    --pad-left(-l): int = 0,        # left padding
    --pad-right(-r): int = 0,       # right padding
    --pad-y(-y): int = 0,           # vertical padding
    --pad-top(-t): int = 0,         # top padding
    --pad-bottom(-b): int = 0,      # bottom padding
    --alignment(-a): string = l     # text alignment for fill (see `fill -h`)
]: any -> list<string> {
    let input = [$in] | each {|e| $e | into string | lines} | flatten
    let max_length = $input | ansi strip | str length -g | math max
    let padding = match $pad {
        n | normal => {
            top: ("" | repeat ([$pad_y $pad_top] | math max))
            bottom: ("" | repeat ([$pad_y $pad_bottom] | math max))
            left: ("" | fill -w ([$pad_x $pad_left 1] | math max))
            right: ("" | fill -w ([$pad_x $pad_right 1] | math max))
        }
        c | comfy => {
            top: ("" | repeat ([$pad_y $pad_top 1] | math max))
            bottom: ("" | repeat ([$pad_y $pad_bottom 1] | math max))
            left: ("" | fill -w ([$pad_x $pad_left 2] | math max))
            right: ("" | fill -w ([$pad_x $pad_right 2] | math max))
        }
        t | tight => {
            top: ("" | repeat ([$pad_y $pad_top] | math max))
            bottom: ("" | repeat ([$pad_y $pad_bottom] | math max))
            left: ("" | fill -w ([$pad_x $pad_left] | math max))
            right: ("" | fill -w ([$pad_x $pad_right] | math max))
        }
    }
    let filled = [
        ...$padding.top
        ...$input
        ...$padding.bottom
    ] | each {|line|
        $line | fill -a $alignment -w $max_length
    }
    let container_width = $max_length + $pad_left + $pad_right
    $filled | each {|line|
        $padding.left + $line + $padding.right
    }
}

export def box []: list<string> -> list<string> {
    let container = $in
    let max_length = $container | ansi strip | str length -g | math max
    let horizontal_border = ("" | fill -c '─' -w $max_length | str join)
    let top_border = $"╭($horizontal_border)╮"
    let middle = $container | each { |line| $"│($line)│" }
    let bottom_border = $"╰($horizontal_border)╯"
    [
        $top_border
        ...$middle
        $bottom_border
    ]
}

# places a container to the right of another container
export def row [
    right: list<string>             # container to place to the right
    --alignment(-a): string = t     # alignment of the right container: top (t), bottom (b), center (c), center_bottom (cb)
    --spacing(-s): int = 1          # number of spaces between the two containers
]: list<string> -> list<string> {
    let left = [$in] | each {|e| $e | into string | lines} | flatten
    let right = [$right] | each {|e| $e | into string | lines} | flatten
    if ($left | length) == 0 {
        return $right
    } else if ($right | length) == 0 {
        return $left
    }
    let tpad = match {left: ($left | length), right: ($right | length)} {
        $h if $h.left == $h.right => {left: 0, right: 0}
        $h if $h.left > $h.right => {left: 0, right: ($h.left - $h.right)}
        $h if $h.left < $h.right => {left: ($h.right - $h.left), right: 0 }
    }
    let padding = match $alignment {
        t | top => { left: {top: 0, bottom: $tpad.left}, right: {top: 0, bottom: $tpad.right} }
        b | bottom => { left: {top: $tpad.left, bottom: 0}, right: {top: $tpad.right, bottom: 0} }
        c | center => {
            left: { top: ($tpad.left / 2 | math floor), bottom: ($tpad.left / 2 | math ceil) }
            right: { top: ($tpad.right / 2 | math floor), bottom: ($tpad.right / 2 | math ceil) }
        }
        cb | center_bottom => {
            left: { top: ($tpad.left / 2 | math ceil), bottom: ($tpad.left / 2 | math floor) }
            right: { top: ($tpad.right / 2 | math ceil), bottom: ($tpad.right / 2 | math floor) }
        }
    }
    let left_pad_line = "" | fill -w ($left | ansi strip | str length -g | math max)
    let right_pad_line = "" | fill -w ($right | ansi strip | str length -g | math max)
    let padding = {
        left: {
            top: ($left_pad_line | repeat $padding.left.top),
            bottom: ($left_pad_line | repeat $padding.left.bottom)
        }
        right: {
            top: ($right_pad_line | repeat $padding.right.top),
            bottom: ($right_pad_line | repeat $padding.right.bottom)
        }
    }
    let left = [
        ...$padding.left.top
        ...$left
        ...$padding.left.bottom
    ]
    let right = [
        ...$padding.right.top
        ...$right
        ...$padding.right.bottom
    ]
    ($left | zip $right) | each { |pair|
        $"($pair.0)("" | fill -w $spacing)($pair.1)"
    }
}

def "container print" []: list<string> -> nothing {
    print ($in | str join "\n")
}

# ---------------------------------------------------------------------------- #

const header = r#'
╭────────────────────────────────╮
│       __  ,                    │
│   .--()°'.'  Nushell v0.105.1  │
│  '|, . ,'    ────────────────  │
│   !_-(_\     Brendon Felix     │
│                                │
╰────────────────────────────────╯
'#

def bar [
    value: float
    --length(-l): int = 12
    --fg-color(-f): any = '#DCDFE4'
    --bg-color(-b): any = '#505050'
    --attr(-a): string
] {
    # asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $value
    let attr = match $attr {
        null => ""
        _ => $attr
    }
    let bar_exe = match $nu.os-info.name {
        "windows" => 'bar.exe'
        "macos" | "linux" => 'bar'
    }
    let bar = ^$bar_exe -l $length $value
    let ansi_color = {
        fg: $fg_color,
        bg: $bg_color,
        attr: $attr,
    }
    $"(ansi -e $ansi_color)($bar)(ansi reset)"
}

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

def memory [--bar(-b)] {
    let memory = sys mem
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round | into int)
    let color = match $proportion_used {
        _ if $proportion_used < 0.6 => 'green'
        _ if $proportion_used < 0.8 => 'yellow'
        _ => 'red'
    }
    let memory_status = $"($memory.used) \(($percent_used)%\)"
    if $bar {
        let memory_bar = bar $proportion_used -f $color
        $"($memory_bar) (ansi $color)($memory_status)(ansi reset)"
    } else {
        $"(ansi $color)($memory_status)(ansi reset)"
    }
}

def header_text []: nothing -> list<string> {
    # let curr_version = match (version check) {
    #     $c if $c.current => $"(ansi green)v($env.NU_VERSION)(ansi reset)"
    #     $c => $"(ansi yellow)v($env.NU_VERSION)(ansi reset)"
    # }
    # let shell = $"(ansi green)Nushell(ansi reset) " + $curr_version
    let shell = $"(ansi green)Nushell v($env.NU_VERSION)(ansi reset)"
    let username = $"(ansi light_purple)($env.USERNAME)(ansi reset)"
    let hostname = sys host | get hostname | str replace '.local' ''
    let hostname = $"(ansi light_purple)($hostname)(ansi reset)"
    let user = $"($username)@($hostname)"

    let width = [($shell | ansi strip | str length -g), ($user | ansi strip | str length -g)] | math max
    let separator = "" | fill -c '─' -w $width
    let max_length = [$shell $separator $user] | ansi strip | str length -g | math max
    [$shell $separator $user] | contain -p t -a l
}

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

def my-ellie []: nothing -> list<string> {
    ellie | ansi strip | contain -x 2 --pad-bottom 1
}

def header []: nothing -> list<string> {
    my-ellie | each { |line| $"(ansi green)($line)(ansi reset)"} | row -s 0 -a c (header_text | contain -p t --pad-top 1 --pad-right 2) | contain -p tight
}

export def `print banner` [
    type? = memory # the type of banner to print: ellie, header, info, row, stack
] {
    banner $type | contain -p t | container print
}

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
def banner [
    type?: string = memory # the type of banner to create: # ellie, user, header, info, info_english, info_record, row, stack, row_english, stack_english, memory, mem_disks, test
]: nothing -> list<string> {
    match $type {
        # ellie => (my-ellie | ansi apply green | box)
        # user => (header_text | contain -p c | box)
        header => (header | box)
        # info => (info_text | contain -p "comfy" | box)
        # info_english => (info_text english | contain -p "comfy" | box)
        # info_record => (info_text record)
        # row => (header | box | row -a b (info_text | contain | box))
        # stack => (header | box | append (info_text | contain | box) | contain -p tight)
        # row_english => (header | box | row -a b (info_text english | contain | box))
        # stack_english => (header | box | append (info_text english | contain | box) | contain -p tight)
        memory => (header | append $"RAM: (memory -b)"| contain -a c | box)
        # mem_disks => (header | append $"("RAM" | ansi apply blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | ansi apply blue): ($status)"}) | contain -a l | box)
        # test => (header | box | row -s 2 -a c (info_text english))
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
