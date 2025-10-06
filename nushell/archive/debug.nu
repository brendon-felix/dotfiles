
# ---------------------------------------------------------------------------- #
#                                   debug.nu                                   #
# ---------------------------------------------------------------------------- #

export alias `debug-builtin` = debug

export def main [x] {
    $env.config.color_config.shape_garbage = 'default'
    let span = (metadata $x).span
    let x_name = view span $span.start $span.end | highlight nu
    let x_type = $"(ansi --escape {fg: '#A0A0A0', bg: '#303030'}): ($x | describe)(ansi reset)"
    print $"($x_name) \(($x_type)\) is currently: ($x | debug-builtin)"
}
