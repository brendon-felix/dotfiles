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

# Paint a path with different colors for the dirname, basename, and separator. Optionally use `ls-colorize`
export def `paint path` [
    colors: record = {
        dirname: 'cyan'
        basename: 'green'
        separator: 'grey69'
    }
    --ls-colorize(-l)  # use ls-colorize to get the color for the basename
]: [
    path -> string
    list<path> -> list<string>
] {
    each {|path|
        mut splits = $path | split row (char path_sep)
        if $nu.os-info.name == windows {
            $splits = $splits | split row '/' | flatten # use '\' and '/' on windows
        }
        let is_dir = $splits | last | is-empty
        if $is_dir { $splits = $splits | drop }
        let last = match $ls_colorize {
            true => ($splits | last | paint with ($path | ls-colorize --get-color))
            false => ($splits | last | main $colors.basename)
        }
        mut colored = $splits | drop | main $colors.dirname | append $last
        if $is_dir { $colored = $colored | append '' }
        $colored | str join (char path_sep | main $colors.separator)
    }
}
