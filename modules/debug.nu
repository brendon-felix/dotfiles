# ---------------------------------------------------------------------------- #
#                                   debug.nu                                   #
# ---------------------------------------------------------------------------- #

use ansi.nu color

export def test [] {
    "test"
}

export def main [x] {
    let type_ansi = {
        fg: '#A0A0A0',
        bg: '#303030',
    }

    let span = (metadata $x).span
    let x = $x
    # let x_name = view span $span.start $span.end | nu-highlight
    let x_name = view span $span.start $span.end | highlight nu # workaround since nu-highlight error highlights variables
    let x_type = $"(ansi --escape $type_ansi): ($x | describe)(ansi reset)"
    print $"($x_name)($x_type) =\n($x)"
}