
# ---------------------------------------------------------------------------- #
#                                   debug.nu                                   #
# ---------------------------------------------------------------------------- #

export alias `debug-builtin` = debug

const TYPE_ANSI = {
    fg: '#A0A0A0',
    bg: '#303030',
}

export def test [] {
    "test"
}

export def main [x] {
    $env.config.color_config.shape_garbage = 'default'
    let span = (metadata $x).span
    let x_name = view span $span.start $span.end | nu-highlight
    let x_type = $"(ansi --escape $TYPE_ANSI): ($x | describe)(ansi reset)"
    print $"($x_name)($x_type) ="
    print ($x | debug-builtin)
}

