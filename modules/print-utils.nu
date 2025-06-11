# ---------------------------------------------------------------------------- #
#                                print-utils.nu                                #
# ---------------------------------------------------------------------------- #

use round.nu 'round duration'
use ansi.nu *

export def bar [value: number] {
    asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $value
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

export def countdown [duration: duration, --no-bar(-b)] {
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
        mut status = $"($remaining | round duration sec)"
        if not $no_bar {
            let bar = bar ($remaining / $duration)
            $status = $"($bar) ($status)"
        }
        print -n $"($status)"
        erase right
        print -n "\r"
        $remaining = $end_time - (date now)
    }
    # print $"(ansi green)("Done")(erase right)(ansi reset)"
    # print -n $"(ansi reset)"
}
