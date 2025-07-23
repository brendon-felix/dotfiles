
# ---------------------------------------------------------------------------- #
#                                   color.nu                                   #
# ---------------------------------------------------------------------------- #

use rgb.nu ['into rgb' 'rgb get-hex']

export const AVAILABLE_ANSI: list<string> = (ansi --list | get name)

# apply ANSI color or attributes to a piped string
export def `ansi apply` [
    color           # the color or escape to apply (see `ansi --list`)
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
]: [
    string -> string
    list<string> -> list<string>
] {
    each { |e|
        let e = match $strip {
            true => ($e | ansi strip),
            false => $e
        }
        match $color {
            $c if ($c | describe) == "string" => {
                match $c {
                    _ if ($c =~ '#([A-Fa-f0-9]{6})') => $"(ansi -e {fg: $c})($e)(ansi reset)"
                    _ if ($c in $AVAILABLE_ANSI) => $"(ansi $c)($e)(ansi reset)"
                    _ => { error make -u { msg: "Invalid string" } }
                }
            }
            $c if ($c | describe) == "record<r: int, g: int, b: int>" => $"(ansi --escape {fg: ($c | into rgb | rgb get-hex)})($e)(ansi reset)"
            $c if ($c | describe) == "record<h: int, s: float, v: float>" => $"(ansi --escape {fg: ($c | into rgb | rgb get-hex)})($e)(ansi reset)"
            $c if ($c | describe | str starts-with "record") => $"(ansi --escape $c)($e)(ansi reset)"
            _ => { error make -u { msg: "Invalid color" } }
        }
    }
}

export def `color interpolate` [
    start,
    end,
    t?: float = 0.5,
    --hsv
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
] {
    let start = if $hsv { $start | into rgb | rgb get-hsv } else { $start | into rgb }
    let end = if $hsv { $end | into rgb | rgb get-hsv } else { $end | into rgb }
    mut color = $start | interpolate $end $t
    if $hsv { $color = $color | rgb from-hsv }
    let hex = $color | rgb get-hex
    $in | each {|e| $e | ansi apply {fg: $hex} --strip=$strip --no-reset=$no_reset}
}

export def `color gradient` [
    start,          # start color (can be RGB or HSV)
    end,            # end color (can be RGB or HSV)
    --hsv           # use HSV color space for interpolation
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
]: string -> string {
    let start = if $hsv { $start | into rgb | rgb get-hsv } else { $start | into rgb }
    let end = if $hsv { $end | into rgb | rgb get-hsv } else { $end | into rgb }
    $in | each {|e|
        let length = $e | str length
        $e | split chars | enumerate | each {|i|
            let t = $i.index / $length
            mut interpolated = $start | interpolate $end $t
            if $hsv { $interpolated = $interpolated | rgb from-hsv }
            let hex = $interpolated | rgb get-hex
            $i.item | ansi apply {fg: $hex} --strip=$strip --no-reset=$no_reset
            # $"(ansi -e {fg: $hex})($e.item)(ansi reset)"
        }
    } | str join
}

export def `color cycle` [i] {
    let colors = [
        "red",
        "green",
        "blue", 
        "yellow",
        "magenta",
        "cyan",
        "white"
    ]
    $in | each {|e|
        let index = ($i | into int) mod ($colors | length)
        $e | ansi apply ($colors | get $index)
    }
}

export def `color random` [
    --hsv
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
] {
    each {|e|
        let color = if $hsv {
            {h: (random float 0..<360), s: (random float 0..<1), v: (random float 0..<1)}
        } else {
            {r: (random int 0..255), g: (random int 0..255), b: (random int 0..255)}
        }
        $e | ansi apply $color --strip=$strip --no-reset=$no_reset
    }
}

