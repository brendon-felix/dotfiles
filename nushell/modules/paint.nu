# ---------------------------------------------------------------------------- #
#                                   paint.nu                                   #
# ---------------------------------------------------------------------------- #

use rgb.nu ['into rgb' 'rgb get-hex']

def "nu-complete paint" [] {
    let list = ansi --list
    $list.name | append $list.short_name
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
            $s if ($s | describe) == "record<r: int, g: int, b: int>" => $"(ansi --escape {fg: ($s | into rgb | rgb get-hex)})($e)(ansi reset)"
            $s if ($s | describe) == "record<h: int, s: float, v: float>" => $"(ansi --escape {fg: ($s | into rgb | rgb get-hex)})($e)(ansi reset)"
            $s if ($s | describe | str starts-with "record") => $"(ansi --escape $s)($e)(ansi reset)"
            _ => { error make -u { msg: "Invalid color" } }
        }
    }
}
