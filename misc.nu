# ---------------------------------------------------------------------------- #
#                                    misc.nu                                   #
# ---------------------------------------------------------------------------- #

use round.nu *

export alias bar = asciibar --empty '░' --half-filled '▓' --filled '█' --length 12

export def "fill line" [char] {
    $in | fill -c $char -w (term size).columns
}

export def box [text] {
    let length = ($text | str length)
    let top_bottom = ('─' | repeat ($length + 2) | str join)
    print $"╭($top_bottom)╮"
    print $"│ ($text    ) │"
    print $"╰($top_bottom)╯"
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

export def mem_used_str [] {
    let memory = (sys mem)
    let mem_used = $memory.used / $memory.total
    let mem_used_bar = bar $mem_used
    let memory_used_display_uncolored = $"($mem_used_bar) ($memory.used) \(($mem_used * 100 | math round --precision 0 )%\)"
    match $mem_used {
        _ if $mem_used < 0.6 => $"(ansi green)($memory_used_display_uncolored)(ansi reset)"
        _ if $mem_used < 0.8 => $"(ansi yellow)($memory_used_display_uncolored)(ansi reset)"
        _ => $"(ansi red)($memory_used_display_uncolored)(ansi reset)"
    }
}