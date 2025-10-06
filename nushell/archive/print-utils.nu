
# ---------------------------------------------------------------------------- #
#                                print-utils.nu                                #
# ---------------------------------------------------------------------------- #

use rgb.nu ['into rgb' 'rgb get-hex']
use ansi.nu ['cursor off' 'cursor on' 'erase right']
# use interpolate.nu main
use round.nu 'round duration'
use paint.nu main

export def `char block` [
    shade?: int = 4
] {
    match $shade {
        1 => "░"
        2 => "▒"
        3 => "▓"
        _ => "█"
    }
}

export def blocks [
    length: int
    --shade(-s): int = 4
] {
    "" | fill -c (char block $shade) -w $length
}

# export def bar [
#     value: float
#     --length(-l): int = 12
#     --fg-color(-f): any = 'white'
#     --bg-color(-b): any = 'gray'
#     --attr(-a): string
# ] {
#     # asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $value
#     let attr = match $attr {
#         null => ""
#         _ => $attr
#     }
#     let bar_exe = match $nu.os-info.name {
#         "windows" => 'bar.exe'
#         "macos" | "linux" => 'bar'
#     }
#     let bar = ^$bar_exe -l $length $value
#     let ansi_color = {
#         fg: ($fg_color | into rgb | rgb get-hex),
#         bg: ($bg_color | into rgb | rgb get-hex),
#         attr: $attr,
#     }
#     $bar | paint $ansi_color
# }

export def bar [
    value: float
    --length(-l): int = 12
    --fg-color(-f): any = '#DCDFE4'
    --bg-color(-b): any = '#505050'
    # --attr(-a): string
] {
    let bar = ^bar -l $length $value
    let ansi_color = {fg: $fg_color, bg: $bg_color}
    $"(ansi -e $ansi_color)($bar)(ansi reset)"
}

export def separator [
    length?: int
    --alignment(-a): string = 'c'
] {
    let input = match $in {
        null => ""
        _ => {match $alignment {
            'l' => $"($in) "
            'c' | 'm' | 'cr' | 'mr' => $" ($in) "
            'r' => $" ($in)"
        }}
    }
    let length = match $length {
        null => (term size).columns
        _ => $length
    }
    $input | fill -a $alignment -c '─' -w $length
}

export def countdown [
    duration: duration
    --no-bar(-b)
    --bar-length(-l): int = 12
    --start-color(-s): any = white
    --end-color(-e): any = white
] {
    if $duration < 1ms {
        error make {
            msg: "invalid duration",
            label: {
                text: "must be greater than or equal to 1ms",
                span: (metadata $duration).span,
            }
        }
    }
    let start_time = date now
    let end_time = $start_time + $duration
    mut $remaining = $duration
    cursor off
    while $remaining > 0sec {
        let proportion = $remaining / $duration
        # let color = ($start_color | into rgb) | interpolate ($end_color | into rgb) $proportion
        let color = 'default'
        mut status = $"($remaining | round duration)" | paint $color
        if not $no_bar {
            let bar = bar --length=$bar_length --fg-color $color ($remaining / $duration)
            $status = $"($bar) ($status)"
        }
        print -n $status
        erase right
        print -n "\r"
        $remaining = $end_time - (date now)
    }
    # print $"(ansi green)("Done")(erase right)(ansi reset)"
    # print -n $"(ansi reset)"
}

export def countup [
    duration: duration
    --no-bar(-b)
    --bar-length(-l): int = 12
    --start-color(-s): any = white
    --end-color(-e): any = white
] {
    if $duration < 1ms {
        error make {
            msg: "invalid duration",
            label: {
                text: "must be greater than or equal to 1ms",
                span: (metadata $duration).span,
            }
        }
    }
    let start_time = date now
    let end_time = $start_time + $duration
    mut $remaining = $duration
    cursor off
    while $remaining > 0sec {
        let proportion = $remaining / $duration
        # let color = ($start_color | into rgb) | interpolate ($end_color | into rgb) $proportion
        let color = 'default'
        mut status = $"(($duration - $remaining) | round duration)" | paint $color
        if not $no_bar {
            let bar = bar --length=$bar_length --fg-color $color (($duration - $remaining) / $duration)
            $status = $"($bar) ($status)"
        }
        print -n $status
        erase right
        print -n "\r"
        $remaining = $end_time - (date now)
    }
    # print $"(ansi green)("Done")(erase right)(ansi reset)"
    # print -n $"(ansi reset)"
}
