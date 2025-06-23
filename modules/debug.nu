# ---------------------------------------------------------------------------- #
#                                   debug.nu                                   #
# ---------------------------------------------------------------------------- #

const TYPE_ANSI = {
    fg: '#A0A0A0',
    bg: '#303030',
}

export def test [] {
    "test"
}

export def main [x] {
    

    let span = (metadata $x).span
    let x = $x
    let x_name = view span $span.start $span.end | nu-highlight
    # let x_name = view span $span.start $span.end | highlight nu # workaround since nu-highlight error highlights variables
    let x_name = view span $span.start $span.end
    let x_type = $"(ansi --escape $TYPE_ANSI): ($x | describe)(ansi reset)"
    print $"($x_name)($x_type) =\n($x)"
}