# ---------------------------------------------------------------------------- #
#                                   path.nu                                    #
# ---------------------------------------------------------------------------- #

use debug.nu *

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

