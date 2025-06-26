# ---------------------------------------------------------------------------- #
#                                   color.nu                                   #
# ---------------------------------------------------------------------------- #

use std ellie
use rgb.nu *
# use container.nu [contain 'container print']
use records.nu 'each value'
use interpolate.nu main
use debug.nu *

# apply ANSI color or attributes to a piped string
export def `color apply` [
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
            $c if ($c | describe) == "string" => $"(ansi $c)($e)(ansi reset)"
            $c if ($c | describe) == "record<r: int, g: int, b: int>" => $"(ansi --escape {fg: ($c | into rgb | rgb get-hex)})($e)(ansi reset)"
            $c if ($c | describe) == "record<h: int, s: float, v: float>" => $"(ansi --escape {fg: ($c | into rgb | rgb get-hex)})($e)(ansi reset)"
            $c if ($c | describe | str starts-with "record") => $"(ansi --escape $c)($e)(ansi reset)"
            _ => {
                error make -u { msg: "Invalid color format" }
            }
        }
    }
}

export def `color background` [$color] {
    $in | color apply $color
}

export def `color interpolate` [
    start,
    end,
    t?: float = 0.5,
    --hsv
] {
    let start = if $hsv { $start | into rgb | rgb get-hsv } else { $start | into rgb }
    let end = if $hsv { $end | into rgb | rgb get-hsv } else { $end | into rgb }
    mut color = $start | interpolate $end $t
    if $hsv { $color = $color | rgb from-hsv }
    let hex = $color | rgb get-hex
    $in | each {|e| $e | color apply {fg: $hex}}
}

export def `color gradient` [
    start,
    end,
    --hsv
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
            $i.item | color apply {fg: $hex}
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
        $e | color apply ($colors | get $index)
    }
}

