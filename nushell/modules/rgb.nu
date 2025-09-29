
# ---------------------------------------------------------------------------- #
#                                    rgb.nu                                    #
# ---------------------------------------------------------------------------- #

use records.nu 'each value'
use format.nu 'format hex'

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
export def `into rgb` []: any -> record<r: int, g: int, b: int> {
    each {|e|
        match $e {
            $s if ($s | describe) == "string" => {match $s {
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
                    error make -u { msg: "Invalid color string" }
                }
            }}
            $s if ($s | describe) == "int" => {
                if $s < 0 or $s > 0xFFFFFF {
                    error make -u { msg: "Hex value out of range" }
                }
                let r = $s | bits shr -n 4 16 | bits and 0xFF
                let g = $s | bits shr -n 4 8| bits and 0xFF
                let b = $s | bits and 0xFF
                {r: $r, g: $g, b: $b}
            }
            $r if ($r | describe) == "record<r: int, g: int, b: int>" => {
                if ($r.r < 0 or $r.r > 255) or ($r.g < 0 or $r.g > 255) or ($r.b < 0 or $r.b > 255) {
                    error make -u { msg: "RGB value out of range" }
                }
                $r
            }
            $h if ($h | describe) == "record<h: int, s: float, v: float>" => {
                if ($h.h < 0 or $h.h >= 360) or ($h.s < 0 or $h.s > 1) or ($h.v < 0 or $h.v > 1) {
                    error make -u { msg: "HSV value out of range" }
                }
                $h | rgb from-hsv
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

export def `color query` [query: string] {
    let query = match $query {
        'red' => "4;9;"
        'green' => "4;10;"
        'yellow' => "4;11;"
        'blue' => "4;12;"
        'magenta' => "4;13;"
        'cyan' => "4;14;"
        'white' => "4;15;"
        'black' => "4;16;"
        'foreground' => "10;"
        'background' => "11;"
        $q => $q
    }
    (term query $'(ansi osc)($query)?(ansi st)' --prefix $'(ansi osc)($query)' --terminator (ansi st) | decode) | parse "rgb:{r}/{g}/{b}" | first | each value {|v| ('0x' + $v | into int) / 0xFFFF * 255.0 | into int }
}

export def red [] {
    # $env.COLORS.RED
    {r: 224, g: 108, b: 117}
}

export def green [] {
    # $env.COLORS.GREEN
    {r: 152, g: 195, b: 121}
}

export def yellow [] {
    # $env.COLORS.YELLOW
    {r: 229, g: 192, b: 123}
}

export def blue [] {    
    # $env.COLORS.BLUE
    {r: 97, g: 175, b: 239}
}

export def magenta [] {
    # $env.COLORS.MAGENTA
    {r: 198, g: 120, b: 221}
}

export def cyan [] {
    # $env.COLORS.CYAN
    {r: 86, g: 182, b: 194}
}

export def white [] {
    # $env.COLORS.WHITE
    {r: 220, g: 223, b: 228}
}

export def black [] {
    # $env.COLORS.BLACK
    {r: 24, g: 24, b: 24}
}

export def gray [] {
    # $env.COLORS.GRAY
    {r: 80, g: 80, b: 80}
}

export def foreground [] {
    # $env.COLORS.FOREGROUND
    {r: 220, g: 223, b: 228}
}

export def background [] {
    # $env.COLORS.BACKGROUND
    {r: 38, g: 38, b: 38}
}

