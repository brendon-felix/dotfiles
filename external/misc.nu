# ---------------------------------------------------------------------------- #
#                                    misc.nu                                   #
# ---------------------------------------------------------------------------- #

use round.nu *

export use ../internal/utils.nu separator

const TYPE_ANSI = {
    fg: '#A0A0A0',
    bg: '#303030',
}


# export def spinner [string] {
#     let spinner = ["⠋", "⠙", "⠸", "⠴", "⠦", "⠇"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
# } 

export def debug [x] {
    let span = (metadata $x).span
    let x_name = view span $span.start $span.end | highlight nu
    let x_type = $"(ansi --escape $TYPE_ANSI): ($x | describe)(ansi reset)"
    print $"($x_name)($x_type) = ($x)"
}

export def "fill line" [char?] {
    let input = $in
    match $char {
        null => ($input | fill -w (term size).columns)
        _ => ($input | fill -c $char -w (term size).columns)
    }
}



export def box [--alignment(-a): string = 'l'] {
    let input = [$in] | flatten
    # debug $input
    let max_length = $input | ansi strip | str length -g | math max
    let top_bottom = ("" | fill -c '─' -w ($max_length + 2) | str join)
    let middle = $input | each { |line| 
        let padded_line = $"($line)" | fill -a $alignment -w $max_length
        $"│ ($padded_line) │"
    }
    $"╭($top_bottom)╮" | append $middle | append $"╰($top_bottom)╯"
}

export def "print box" [input, --alignment(-a): string = 'l'] {
    let boxed = ($"($input)" | box --alignment $alignment)
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
    while $remaining > 0sec {
        let proportion = $remaining / $duration
        mut status = $"($remaining | round duration sec)"
        if $bar {
            let bar = bar ($remaining / $duration)
            $status = $"($bar) ($status)"
        }
        print -n $"($status | fill line ' ')\r"
        $remaining = $end_time - (date now)
    }
    print $"(ansi green)("Done" | fill line ' ')(ansi reset)"
}

export def shutdown [] {
    run-external 'shutdown' '/s' '/t' '0'
}

export def reboot [] {
    run-external 'shutdown' '/r' '/t' '0'
}

export def "config nu" [] {
    code ~/Projects/nushell-scripts/config.nu
}

export def srev [] {
	$in | sort-by modified | reverse
}

# Send a request to Wolfram Alpha and print the response
export def wa [...input: string] {
    let APPID = open ~/wolfram_appid.txt | str trim
    let question_string = $input | str join ' ' | url encode
    # debug $question_string
    let url = (["https://api.wolframalpha.com/v1/result?appid=", $APPID, "&i=", $question_string] | str join)
    curl $url
}