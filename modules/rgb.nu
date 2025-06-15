# ---------------------------------------------------------------------------- #
#                                    rgb.nu                                    #
# ---------------------------------------------------------------------------- #

use core.nu ['str remove' 'each value' 'format hex']
use debug.nu *

# Convert an RGB record to a hex string
export def rgb-to-hex []: record<r: int, g: int, b: int> -> string {
    each {|e|
        let rgb = $e | each value {|v|
            if $v < 0 or $v > 255 {
                error make -u { msg: "RGB value out of range" }
            }
            $v | format hex -r -w 2
        }
        $"#($rgb.r)($rgb.g)($rgb.b)"
    }
}

# Convert a hex string to an RGB record
export def `into rgb` []: string -> record<r: int, g: int, b: int> {
    each {|e|
        match $e {
            red => { r: 255, g: 0, b: 0 }
            green => { r: 0, g: 255, b: 0 }
            blue => { r: 0, g: 0, b: 255 }
            yellow => { r: 255, g: 255, b: 0 }
            cyan => { r: 0, g: 255, b: 255 }
            magenta => { r: 255, g: 0, b: 255 }
            black => { r: 0, g: 0, b: 0 }
            white => { r: 255, g: 255, b: 255 }
            gray => { r: 128, g: 128, b: 128 }
            light_red => { r: 255, g: 128, b: 128 } 
            light_green => { r: 128, g: 255, b: 128 }
            light_blue => { r: 128, g: 128, b: 255 }
            light_yellow => { r: 255, g: 255, b: 128 }
            light_cyan => { r: 128, g: 255, b: 255 }
            light_magenta => { r: 255, g: 128, b: 255 }
            _ if ($e | str starts-with '#') and ($e | str length == 7) => {
                let parsed = $e | parse -r '#(?<r>[0-9a-fA-F]{2})(?<g>[0-9a-fA-F]{2})(?<b>[0-9a-fA-F]{2})' | first
                $parsed | each value {|v| ('0x' + $v | into int)}
            }
            _ if ($e | str starts-with '0x') and ($e | str length == 8) => {
                let parsed = $e | parse -r '0x(?<r>[0-9a-fA-F]{2})(?<g>[0-9a-fA-F]{2})(?<b>[0-9a-fA-F]{2})' | first
                $parsed | each value {|v| ('0x' + $v | into int)}
            }
            _ => {
                error make -u { msg: "Invalid hex color format" }
            }

        }
        
    }
}

# Convert an RGB record to HSV
export def rgb-to-hsv []: [
    record<r: int, g: int, b: int> -> record<h: int, s: float, v: float>
] {
    each {|e|
        let $e = $e | each value {|v|
            if $v < 0 or $v > 255 {
                error make -u { msg: "RGB value out of range" }
            }
            $v / 255.0
        }
        let cmax = [$e.r, $e.g, $e.b] | math max
        let cmin = [$e.r, $e.g, $e.b] | math min
        let delta = $cmax - $cmin
        let h = match $cmax {
            _ if $delta == 0 => 0,
            _ if $cmax == $e.r => ((($e.g - $e.b) / $delta) * 60),
            _ if $cmax == $e.g => ((($e.b - $e.r) / $delta + 2) * 60),
            _ if $cmax == $e.b => ((($e.r - $e.g) / $delta + 4) * 60),
            _ => 0
        }
        let h = ($h | into int) mod 360
        let s = if $cmax == 0 { 0.0 } else { $delta / $cmax }
        let v = $cmax
        { h: $h, s: $s, v: $v }
    }
}

export def interpolate-hsv [
    start: record<h: int, s: float, v: float>
    end: record<h: int, s: float, v: float> 
    t: float
] {
    match $t {
        $t if $t <= 0 => $start
        $t if $t >= 1 => $end
        _ => {
            let h = $start.h + ($end.h - $start.h) * $t | into int
            let s = $start.s + ($end.s - $start.s) * $t
            let v = $start.v + ($end.v - $start.v) * $t
            { h: $h, s: $s, v: $v }
        }
    }
}

export def hsv-to-rgb []: [
    record<h: int, s: float, v: float> -> record<r: int, g: int, b: int>
] {
    each {|e|
        let c = $e.v * $e.s
        let x = $c * (1 - ((($e.h / 60) mod 2) - 1 | math abs))
        let m = $e.v - $c
        let rgb = match ($e.h / 60) {
            $h if $h < 1 => {r: $c, g: $x, b: 0},
            $h if $h < 2 => {r: $x, g: $c, b: 0},
            $h if $h < 3 => {r: 0, g: $c, b: $x},
            $h if $h < 4 => {r: 0, g: $x, b: $c},
            $h if $h < 5 => {r: $x, g: 0, b: $c},
            _ => {r: $c, g: 0, b: $x}
        }
        $rgb | each value {|v| (($v + $m) * 255 | into int)}
    }
}

export def `color interpolate` [
    start: string,
    end: string,
    t: float,
] {
    let start = $start | into rgb | rgb-to-hsv
    let end = $end | into rgb | rgb-to-hsv
    let color = interpolate-hsv $start $end $t | hsv-to-rgb | rgb-to-hex
    $in | each {|e| $e | color -e {fg: $color}}
}

# export def main [] {
#     $in | into rgb
# }