# ---------------------------------------------------------------------------- #
#                                    ansi.nu                                   #
# ---------------------------------------------------------------------------- #

export def bold [] {
    each { |e|
        $"(ansi attr_bold)($e)(ansi reset)"
    }
}

export def italicize [] {
    each { |e|
        $"(ansi attr_italic)($e)(ansi reset)"
    }
}

export def strike [] {
    each { |e|
        $"(ansi attr_strike)($e)(ansi reset)"
    }
}

export def dim [] {
    each { |e|
        $"(ansi attr_dimmed)($e)(ansi reset)"
    }
}

export def hide [] {
    each { |e|
        $"(ansi attr_hidden)($e)(ansi reset)"
    }
}

export def blink [] {
    each { |e|
        $"(ansi attr_blink)($e)(ansi reset)"
    }
}

export def `strip length` []: string -> int {
    $in | ansi strip | str length -g
}

# apply ANSI color or attributes to a piped string
export def color [
    color           # the color or escape to apply (see `ansi --list`)
    --escape(-e)    # use <color> as a custom escape (using `ansi --escape`)
] {
    if $escape == false {
        if not ($color in (ansi --list | get name)) {
            error make {
                msg: "invalid color"
                label: {
                    text: "color not recognized"
                    span: (metadata $color).span
                }
                help: "Use `ansi --list` to see available colors."
            }
        }
    }
    $in | each { |e|
        $"(ansi --escape=$escape $color)($e | into string | ansi strip)(ansi reset)"
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