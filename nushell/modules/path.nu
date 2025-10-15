# ---------------------------------------------------------------------------- #
#                                   path.nu                                    #
# ---------------------------------------------------------------------------- #

use paint.nu [main 'paint with']

# Get a path's parent directory, with options to get n levels up and return only the basename
export def `path parent` [
    n: int = 1
    --basename(-b)
]: [
    path -> path
    list<path> -> list<path>
] {
    each {|e|
        let split = $e | path expand | path split
        let m = ($split | length) - 1
        if $n > $m {
            error make {
                msg: $"cannot get parent directory up ($n) levels",
                label: {
                    text: $"path has only ($m) parent directories",
                    span: (metadata $n).span
                }
            }
        }
        match $basename {
            true => ($split | drop $n | path join | path basename)
            false => ($split | drop $n | path join)
        }
    }
}

# Expand a path and return only the last n components
export def `path expand-by` [n: int = 1]: [
    path -> path
    list<path> -> list<path>
] {
    each {|e|
        let unexpanded = $e | path split
        let unexpanded_length = $unexpanded | length
        let expanded = $e | path expand | path split
        let m = ($expanded | length) - $unexpanded_length
        let n = [$m $n] | math min
        $expanded | last ($n + $unexpanded_length) | path join
    }
}

# Get a slice of the components of a path
export def `path slice` [range: range]: [
    path -> path
    list<path> -> list<path>
] {
    each {|e|
        let split = $e | path split
        $split | slice $range | path join
    }
}

# Append a string to the stem of a path, replacing spaces with a separator
export def `path stem-append` [
    s: string
    --separator(-s): string = '_'
]: [
    path -> path
    list<path> -> list<path>
] {
    each {|e|
        mut parsed = $e | path parse
        $parsed.stem += $separator + ($s | str replace --all ' ' $separator)
        $parsed | path join
    }
}

# Highlight the different parts of a path with different colors
export def `path highlight` [
    colors: record = {
        dirname: 'green'
        basename: 'purple'
        separator: 'cyan'
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
            false => ($splits | last | paint $colors.basename)
        }
        mut colored = $splits | drop | paint $colors.dirname | append $last
        if $is_dir { $colored = $colored | append '' }
        $colored | str join (char path_sep | paint $colors.separator)
    }
}
