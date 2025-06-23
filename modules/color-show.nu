# ---------------------------------------------------------------------------- #
#                                 color-show.nu                                #
# ---------------------------------------------------------------------------- #

use banner.nu my-ellie
use container.nu ['container print' row]
use color.nu 'color apply'
use rgb.nu ['rgb from-hsv' 'rgb get-hex' 'into rgb']

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
            $container = $container | row (my-ellie | color apply $ansi_color)
        }
        $container | container print
    }
}
