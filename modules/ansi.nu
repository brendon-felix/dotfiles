# ---------------------------------------------------------------------------- #
#                                    ansi.nu                                   #
# ---------------------------------------------------------------------------- #

export def `strip length` []: string -> int {
    $in | ansi strip | str length -g
}

# -------------------------------- formatting -------------------------------- #

export def bold [] {
    each { |e|
        $"(ansi attr_bold)($e)(ansi reset)"
    }
}

export def dimmed [] {
    each { |e|
        $"(ansi attr_dimmed)($e)(ansi reset)"
    }
}

export def italic [] {
    each { |e|
        $"(ansi attr_italic)($e)(ansi reset)"
    }
}

export def underline [] {
    each { |e|
        $"(ansi attr_underline)($e)(ansi reset)"
    }
}

export def blink [] {
    each { |e|
        $"(ansi attr_blink)($e)(ansi reset)"
    }
}

export def hidden [] {
    each { |e|
        $"(ansi attr_hidden)($e)(ansi reset)"
    }
}

export def strike [] {
    each { |e|
        $"(ansi attr_strike)($e)(ansi reset)"
    }
}

# ------------------------------ cursor commands ----------------------------- #

export def `erase right` [] {
    print -n $"(ansi erase_line_from_cursor_to_end)"
}

export def `erase left` [] {
    print -n $"(ansi erase_line_from_cursor_to_beginning)"
}

export def erase [] {
    print -n $"(ansi erase_line)"
}

export def `cursor off` [] {
    print -n $"(ansi cursor_off)"
}

export def `cursor on` [] {
    print -n $"(ansi cursor_on)"
}

export def `cursor home` [] {
    print -n $"(ansi cursor_home)"
}

export def `cursor blink` [] {
    print -n $"(ansi cursor_blink_on)"
}

export def `cursor left` [] {
    print -n $"(ansi cursor_left)"
}

export def `cursor right` [] {
    print -n $"(ansi cursor_right)"
}

export def `cursor up` [] {
    print -n $"(ansi cursor_up)"
}

export def `cursor down` [] {
    print -n $"(ansi cursor_down)"
}
