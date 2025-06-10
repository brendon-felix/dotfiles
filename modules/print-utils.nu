# ---------------------------------------------------------------------------- #
#                                print-utils.nu                                #
# ---------------------------------------------------------------------------- #

use cursor.nu ['erase right' 'cursor off']
use round.nu 'round duration'
use std repeat


export def bar [value: number] {
    asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $value
}

export def separator [--alignment(-a): string = 'c'] {
    let input = match $in {
        null => ""
        _ => {match $alignment {
            'l' => $"($in) "
            'c' | 'm' | 'cr' | 'mr' => $" ($in) "
            'r' => $" ($in)"
        }}
    }
    $input | fill -a $alignment -c '─' -w (term size).columns
}

export def debug [x] {
    let type_ansi = {
        fg: '#A0A0A0',
        bg: '#303030',
    }

    let span = (metadata $x).span
    let x_name = view span $span.start $span.end | highlight nu
    let x_type = $"(ansi --escape $type_ansi): ($x | describe)(ansi reset)"
    print $"($x_name)($x_type) = ($x)"
}

export def "fill line" [char?] {
    let input = $in
    match $char {
        null => ($input | fill -w (term size).columns)
        _ => ($input | fill -c $char -w (term size).columns)
    }
}

export def pad [width: int] {
    let input = [$in] | each {|e| $e | into string | lines} | flatten
    let max_length = $input | ansi strip | str length -g | math max
}

export def align [alignment: string] {
    mut input = [$in] | each {|e| $e | into string | lines} | flatten
    let max_length = $input | ansi strip | str length -g | math max
    $input | each { |line| 
        let line = $"($line)" | fill -a $alignment -w $max_length
    }
}

export def box [
    --pad-x(-x): int = 1,
    --pad-left(-l): int = 1,
    --pad-right(-r): int = 1,
    --pad-y(-y): int = 0,
    --pad-top(-t): int = 0,
    --pad-bottom(-m): int = 0,
    --alignment(-a): string = 'l',
    --no-border(-b)
] {
    mut input = [$in] | each {|e| $e | into string | lines} | flatten
    let pad_top = ([$pad_y $pad_top] | math max)
    let pad_bottom = ([$pad_y $pad_bottom] | math max)
    $input = $input | prepend ("" | repeat $pad_top) | append ("" | repeat $pad_bottom)
    # debug $input
    let max_length = $input | ansi strip | str length -g | math max
    let pad_left = match $pad_x { 0 => 0, _ => ([$pad_x $pad_left] | math max) }
    let pad_right = match $pad_x { 0 => 0, _ => ([$pad_x $pad_right] | math max) }
    let box_width = $max_length + $pad_left + $pad_right
    mut middle = $input | each { |line| 
        let filled = $line | fill -a $alignment -w $max_length
        let padded_line = (' ' | repeat $pad_left | str join) + $filled + (' ' | repeat $pad_right | str join)
        if $no_border {
            $"($padded_line)"
        } else {
            $"│($padded_line)│"
        }
    }
    if $no_border {
        $middle
    } else {
        let horizontal_border = ("" | fill -c '─' -w $box_width | str join)
        $middle | prepend $"╭($horizontal_border)╮" | append $"╰($horizontal_border)╯"
    }
}

export def "print box" [--alignment(-a): string = 'l', ...input] {
    let boxed = ($input | box --alignment $alignment)
    for line in $boxed {
        print $line
    }
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
        print -n $"($status)(erase right)\r"
        $remaining = $end_time - (date now)
    }
    print $"(ansi green)("Done")(erase right)(ansi reset)"
    # print -n $"(ansi reset)"
}
