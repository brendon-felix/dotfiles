
# ---------------------------------------------------------------------------- #
#                                 color-show.nu                                #
# ---------------------------------------------------------------------------- #

use rgb.nu ['rgb get-hex' 'into rgb' 'rgb from-hsv']
use color.nu 'ansi apply'
use container.nu ['row' 'container print']

export def `color show` [] {
    $in | each {|e|
        let color_hex = match ($e | describe) {
            "record<r: int, g: int, b: int>" => $e
            "record<h: int, s: float, v: float>" => ($e | rgb from-hsv)
            _ => ($e | into rgb)
        } | rgb get-hex
        let ansi_colors = [
            {fg: $color_hex},
            {bg: $color_hex},
            {fg: $color_hex, attr: 'r'},
            {bg: $color_hex, attr: 'r'},
        ]
        mut container = []
        for ansi_color in $ansi_colors {
            # print $"(ansi -e $ansi_color)(ansi reset)"
            $container = $container | row (my-ellie | ansi apply $ansi_color)
        }
        $container | container print
    }
}

export def `print window` [] {
    let container = [
        "╭────┬────╮"
        "│    │    │"
        "├────┼────┤"
        "│    │    │"
        "╰────┴────╯"
    ]
    $container | container print
}

