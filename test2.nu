use modules/core.nu interpolate

use modules/rgb.nu *

use modules/debug.nu *

use modules/tools.nu mix

use modules/round.nu 'round duration'

def main [] {
    # let color1 = { r: 0, g: 255, b: 0 } | rgb get-hsv
    let color1 = { r: 255, g: 102, b: 0 }
    let color2 = { r: 0, g: 102, b: 255 }
    let color1 = { r: 255, g: 102, b: 0 }
    let color2 = { r: 0, g: 102, b: 255 }
    let color1_hsv = $color1 | rgb get-hsv
    let color2_hsv = $color2 | rgb get-hsv
    let length = 100
    # debug $color1_hsv
    # debug $color2_hsv
    # let interpolated = interpolate $color1_hsv $color2_hsv 0.95
    # debug $interpolated
    # let hex = $interpolated | rgb from-hsv | rgb get-hex
    # debug $hex
    # let ansi_color = {fg: $hex}
    # print $"(ansi -e $ansi_color)███████████████████████████(ansi reset)"

    # for c in (1..($length / 2)) {
    #     let hex = $color1 | rgb get-hex
    #     let ansi_color = {fg: $hex}
    #     print -n $"(ansi -e $ansi_color)█(ansi reset)"
    # }

    # for c in (1..($length / 2)) {
    #     let hex = $color2 | rgb get-hex
    #     let ansi_color = {fg: $hex}
    #     print -n $"(ansi -e $ansi_color)█(ansi reset)"

    let start_time = date now
    print -n "HSV: "


    for c in (1..$length) {
        let t = $c / $length
        let interpolated = $color1_hsv | interpolate $color2_hsv $t
        # print $interpolated.h
        let hex = $interpolated | rgb from-hsv | rgb get-hex
        let ansi_color = {fg: $hex}
        print -n $"(ansi -e $ansi_color)█(ansi reset)"
    }

    let duration = (date now) - $start_time
    print $"\nDuration: ($duration | round duration ms)"

    let start_time = date now

    print -n "MIX: "

    for c in (1..$length) {
        let hex = mix ($color1 | rgb get-hex) ($color2 | rgb get-hex) ($c / $length)
        let ansi_color = {fg: $hex}
        print -n $"(ansi -e $ansi_color)█(ansi reset)"
    }

    let duration = (date now) - $start_time
    print $"\nDuration: ($duration | round duration ms)"

    let start_time = date now

    print -n "RGB: "
    for c in (1..$length) {
        let t = $c / $length
        let interpolated = {r: ($color1.r + ($color2.r - $color1.r) * $t | into int),
                           g: ($color1.g + ($color2.g - $color1.g) * $t | into int),
                           b: ($color1.b + ($color2.b - $color1.b) * $t | into int)}
        let hex = $interpolated | rgb get-hex
        let ansi_color = {fg: $hex}
        print -n $"(ansi -e $ansi_color)█(ansi reset)"
    }

    let duration = (date now) - $start_time
    print $"\nDuration: ($duration | round duration ms)"


    let start_time = date now
    print -n "NU:  "
    let start = $color1 | rgb get-hex | str replace '#' '0x'
    let end = $color2 | rgb get-hex | str replace '#' '0x'
    print $"("" | fill -c '█' -w $length | ansi gradient --fgstart $start --fgend $end)"

    let duration = (date now) - $start_time
    print $"Duration: ($duration | round duration ms)"


    # for t in (0..0.05..1) {
    #     let interpolated = interpolate $color1 $color2 $t
    #     let hex = $interpolated | rgb from-hsv | rgb get-hex
    #     let ansi_color = {fg: $hex}
    #     print -n $"(ansi -e $ansi_color)█(ansi reset)"
    # }
    # loop {
    #     for t in (0..0.01..1) {
    #         let interpolated = interpolate $color1 $color2 $t
    #         let hex = $interpolated | rgb from-hsv | rgb get-hex
    #         let ansi_color = {fg: $hex}
    #         print -n $"(ansi -e $ansi_color)███████████████████████████(ansi reset)\r"
    #         sleep 10ms
    #     }
    #     for t in (1..0.99..0) {
    #         let interpolated = interpolate $color1 $color2 $t
    #         let hex = $interpolated | rgb from-hsv | rgb get-hex
    #         let ansi_color = {fg: $hex}
    #         print -n $"(ansi -e $ansi_color)███████████████████████████(ansi reset)\r"
    #         sleep 10ms
    #     }
    # }
}

