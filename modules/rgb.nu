# ---------------------------------------------------------------------------- #
#                                    rgb.nu                                    #
# ---------------------------------------------------------------------------- #

use core.nu ['str remove' 'each value' 'format hex']
# use container.nu [contain 'container print']
use debug.nu *

# Convert an RGB record to a hex string
export def `rgb get-hex` []: record<r: int, g: int, b: int> -> string {
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
            "red"           => (red)
            "green"         => (green)
            "blue"          => (blue)
            "yellow"        => (yellow)
            "cyan"          => (cyan)
            "magenta"       => (magenta)
            "black"         => (black)
            "white"         => (white)
            "gray"          => (gray)
            "light_red"     => (light_red)
            "light_green"   => (light_green)
            "light_blue"    => (light_blue)
            "light_yellow"  => (light_yellow)
            "light_cyan"    => (light_cyan)
            "light_magenta" => (light_magenta)
            _ if ($e | str starts-with '#') and (($e | str length) == 7) => {
                let parsed = $e | parse -r '#(?<r>[0-9a-fA-F]{2})(?<g>[0-9a-fA-F]{2})(?<b>[0-9a-fA-F]{2})' | first
                $parsed | each value {|v| ('0x' + $v | into int)}
            }
            _ if ($e | str starts-with '0x') and (($e | str length) == 8) => {
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
export def `rgb get-hsv` []: [
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

export def `rgb from-hsv` []: [
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

def query_color [query] {
    (term query $'(ansi osc)($query)?(ansi st)' --prefix $'(ansi osc)($query)' --terminator (ansi st) | decode) | parse "rgb:{r}/{g}/{b}" | first | each value {|v| ('0x' + $v | into int) / 0xFFFF * 255.0 | into int }
}

export def red [] {
    query_color "4;9;"
}

export def green [] {
    query_color "4;10;"
}

export def yellow [] {
    query_color "4;11;"
}

export def blue [] {
    query_color "4;12;"
}

export def magenta [] {
    query_color "4;13;"
}

export def cyan [] {
    query_color "4;14;"
}

export def white [] {
    query_color "4;15;"
}

export def black [] {
    query_color "4;16;"
}

export def foreground [] {
    query_color "10;"
}

export def background [] {
    query_color "11;"
}

