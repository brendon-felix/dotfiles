# ---------------------------------------------------------------------------- #
#                                    misc.nu                                   #
# ---------------------------------------------------------------------------- #


def box [text] {
    let length = ($text | str length)
    let top_bottom = ('─' | repeat ($length + 2) | str join)
    print $"╭($top_bottom)╮"
    print $"│ ($text    ) │"
    print $"╰($top_bottom)╯"
}

def shutdown [] {
    run-external 'shutdown' '/s' '/t' '0'
}

def reboot [] {
    run-external 'shutdown' '/r' '/t' '0'
}

def "config nu" [] {
    code ~/Projects/nushell-scripts/config.nu
}

def srev [] {
	$in | sort-by modified | reverse
}

def mem_used_str [] {
    let memory = (sys mem)
    let mem_used = $memory.used / $memory.total
    let mem_used_bar = (asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $mem_used)
    let memory_used_display_uncolored = $"($mem_used_bar) ($memory.used) \(($mem_used * 100 | math round --precision 0 )%\)"
    match $mem_used {
        _ if $mem_used < 0.6 => $"(ansi green)($memory_used_display_uncolored)(ansi reset)"
        _ if $mem_used < 0.8 => $"(ansi yellow)($memory_used_display_uncolored)(ansi reset)"
        _ => $"(ansi red)($memory_used_display_uncolored)(ansi reset)"
    }
}