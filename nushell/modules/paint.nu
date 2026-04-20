# ---------------------------------------------------------------------------- #
#                                   paint.nu                                   #
# ---------------------------------------------------------------------------- #

use color.nu ['into rgb' 'into hsv' 'format rgb' 'color gradient']

def "nu-complete paint" [] {
    let list = ansi --list
    let names = $list.name | compact --empty
    let short_names = $list.short_name | compact --empty
    $names | append $short_names
}

# Apply ANSI styles to text
export def main [
    style: string@"nu-complete paint" # the color or escape to apply (see `ansi --list`)
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
]: [
    any -> string
    list<any> -> list<string>
] {
    each {|e|
        mut result = (ansi $style)
        match $strip {
            true => ($result += ($e | into string | ansi strip))
            false => ($result += ($e | into string))
        }
        match $no_reset {
            true => (),
            false => ($result += (ansi reset))
        }
        $result
    }
}

# Apply ANSI styles to text, with finer control over style input and support for hex/rgb/hsv
export def `paint with` [
    style: any
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
]: [
    any -> string
    list<any> -> list<string>
] {
    each {|e|
        let e = match $strip {
            true => ($e | into string | ansi strip)
            false => ($e | into string)
        }
        match $style {
            $s if ($s | describe) == "string" => {
                match $s {
                    _ if ($s =~ '#([A-Fa-f0-9]{6})') => $"(ansi -e {fg: $s})($e)(ansi reset)"
                    _ if ($s in (nu-complete paint)) => $"(ansi $s)($e)(ansi reset)"
                    _ => { error make -u { msg: $"Invalid string: ($s)" } }
                }
            }
            $s if ($s | describe) == "record<r: int, g: int, b: int>" => $"(ansi --escape {fg: ($s | into rgb | format rgb)})($e)(ansi reset)"
            $s if ($s | describe) == "record<h: int, s: float, v: float>" => $"(ansi --escape {fg: ($s | into rgb | format rgb)})($e)(ansi reset)"
            $s if ($s | describe) == "record<L: float, a: float, b: float>" => $"(ansi --escape {fg: ($s | into rgb | format rgb)})($e)(ansi reset)"
            $s if ($s | describe | str starts-with "record") => $"(ansi --escape $s)($e)(ansi reset)"
            _ => { error make -u { msg: "Invalid color" } }
        }
    }
}

export def `paint gradient` [
    start: oneof<
        record<r: int, g: int, b: int>
        record<h: int, s: float, v: float>
        record<L: float, a: float, b: float>
    > # start color (can be RGB or HSV)
    end: oneof<
        record<r: int, g: int, b: int>
        record<h: int, s: float, v: float>
        record<L: float, a: float, b: float>
    > # end color (can be RGB or HSV)
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying color
]: [
    string -> string
    list<string> -> list<string>
] {
    match $in {
        $i if ($i | describe) == "string" => {
            let input = if $strip { $in | ansi strip } else { $in }
            let gradient = $start | color gradient $end ($input | str length --chars)
            $input | split chars | zip $gradient | each {|e|
                let char = $e.0
                let color = $e.1
                $char | paint with $color --strip=$strip --no-reset=$no_reset
            } | str join
        },
        $i if ($i | describe) == "list<string>" => {
            let gradient = $start | color gradient $end ($i | length)
            $in | zip $gradient | each {|e|
                let s = $e.0
                let color = $e.1
                $s | paint with $color --strip=$strip --no-reset=$no_reset
            }
        },
        _ => { error make -u { msg: "Input must be a string or list of strings" } }
    }
}
