# ---------------------------------------------------------------------------- #
#                                print-utils.nu                                #
# ---------------------------------------------------------------------------- #

use std repeat
use round.nu 'round duration'
use ansi.nu ['cursor off' 'erase right']
use color.nu ['color apply' 'color interpolate']
use interpolate.nu main
use rgb.nu *
# use debug.nu *

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

export def bar [
    value: float
    --length(-l): int = 12
    --fg-color(-f): any = 'white'
    --bg-color(-b): any = 'gray'
    --attr(-a): string
] {
    # asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $value
    let attr = match $attr {
        null => ""
        _ => $attr
    }
    let bar = ~/Projects/bar/target/release/bar.exe -l $length $value
    let ansi_color = {
        fg: ($fg_color | into rgb | rgb get-hex),
        bg: ($bg_color | into rgb | rgb get-hex),
        attr: $attr,
    }
    $bar | color apply $ansi_color
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
    --end-color(-e): any = gray
] {
    if $duration < 1sec {
        error make {
            msg: "invalid duration",
            label: {
                text: "must be greater than or equal to 1sec",
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
        let color = ($start_color | into rgb) | interpolate ($end_color | into rgb) $proportion
        mut status = $"($remaining | round duration sec)" | color apply $color
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
