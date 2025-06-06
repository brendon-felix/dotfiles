# ---------------------------------------------------------------------------- #
#                                print-utils.nu                                #
# ---------------------------------------------------------------------------- #

use cursor.nu ['erase right' 'cursor off']
use round.nu 'round duration'


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

# export def "fill line" [char?] {
#     let input = $in
#     match $char {
#         null => ($input | fill -w (term size).columns)
#         _ => ($input | fill -c $char -w (term size).columns)
#     }
# }

export def box [--alignment(-a): string = 'l'] {
    let input = [$in] | each {|e| $e | into string | lines} | flatten
    # debug $input
    let max_length = $input | ansi strip | str length -g | math max
    let top_bottom = ("" | fill -c '─' -w ($max_length + 2) | str join)
    let middle = $input | each { |line| 
        let padded_line = $"($line)" | fill -a $alignment -w $max_length
        $"│ ($padded_line) │"
    }
    $"╭($top_bottom)╮" | append $middle | append $"╰($top_bottom)╯"
}

export def "print box" [--alignment(-a): string = 'l', ...input] {
    let boxed = ($input | box --alignment $alignment)
    for line in $boxed {
        print $line
    }
}


export def countdown [duration: duration, --bar(-b)] {
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
        if $bar {
            let bar = bar ($remaining / $duration)
            $status = $"($bar) ($status)"
        }
        print -n $"($status)(ansi erase_line_from_cursor_to_end)\r"
        $remaining = $end_time - (date now)
    }
    print $"(ansi green)("Done")(erase right)(ansi reset)"
    # print -n $"(ansi reset)"
}
