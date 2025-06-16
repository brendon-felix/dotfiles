# ---------------------------------------------------------------------------- #
#                                   color.nu                                   #
# ---------------------------------------------------------------------------- #

use std ellie
use rgb.nu *
# use container.nu [contain 'container print']
use core.nu ['each value' interpolate]
use debug.nu *

# apply ANSI color or attributes to a piped string
export def `color apply` [
    color           # the color or escape to apply (see `ansi --list`)
    --escape(-e)    # use <color> as a custom escape (using `ansi --escape`)
    --strip(-s)     # strip ANSI codes from input before applying color
] {
    if $escape == false {
        if not ($color in (ansi --list | get name)) {
            error make {
                msg: "invalid color"
                label: {
                    text: "color not recognized"
                    span: (metadata $color).span
                }
                help: "Use `ansi --list` to see available colors."
            }
        }
    }
    $in | each { |e|
        let e = match $strip {
            true => ($e | ansi strip),
            false => $e
        }
        $"(ansi --escape=$escape $color)($e)(ansi reset)"
    }
}

export def `color background` [$color] {
    $in | color apply -e {bg: $color}
}

export def `color interpolate` [
    start: string,
    end: string,
    t?: float = 0.5,
    --hsv
] {
    let start = if $hsv { $start | into rgb | rgb get-hsv } else { $start | into rgb }
    let end = if $hsv { $end | into rgb | rgb get-hsv } else { $end | into rgb }
    mut color = $start | interpolate $end $t
    if $hsv { $color = $color | rgb from-hsv }
    let hex = $color | rgb get-hex
    $in | each {|e| $e | color apply -e {fg: $hex}}
}

export def `color gradient` [
    start: string,
    end: string,
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
            $i.item | color apply -e {fg: $hex}
            # $"(ansi -e {fg: $hex})($e.item)(ansi reset)"
        }
    } | str join
}



