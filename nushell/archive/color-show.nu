
# ---------------------------------------------------------------------------- #
#                                 color-show.nu                                #
# ---------------------------------------------------------------------------- #

use std ellie
use rgb.nu ['rgb get-hex' 'into rgb' 'rgb from-hsv']
use paint.nu main
use container.nu ['contain' 'row' 'container print']

def my-ellie []: nothing -> list<string> {
    ellie | ansi strip | contain -x 2 --pad-bottom 1
}

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
            $container = $container | row (my-ellie | each {|e| $"(ansi -e $ansi_color)($e)(ansi reset)"})
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
