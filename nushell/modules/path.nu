# ---------------------------------------------------------------------------- #
#                                   path.nu                                    #
# ---------------------------------------------------------------------------- #

use paint.nu main

export def `path parent` [
    n: int = 1
    --basename(-b)
]: [
    string -> string
    list<string> -> list<string>
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

export def `path expand-by` [n: int = 1]: [
    string -> string
    list<string> -> list<string>
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

export def `path slice` [range: range]: [
    string -> string
    list<string> -> list<string>
] {
    each {|e|
        let split = $e | path split
        $split | slice $range | path join
    }
}

export def `path stem-append` [
    s: string
    --separator(-s): string = '_'
] {
    each {|e|
        mut parsed = $e | path parse
        $parsed.stem += $separator + $s
        $parsed | path join
    }
}

export def `path highlight` []: [
    path -> string
    list<path> -> list<string>
] {
    each {|path|
        mut splits = $path | split row (char path_sep)
        if $nu.os-info.name == windows {
            $splits = $splits | split row '/' | flatten # use '\' and '/' on windows
        }
        let last = $splits | last | paint purple
        let colored = $splits | drop | paint green | append $last
        $colored | str join (char path_sep | paint cyan)
    }
}
