# ---------------------------------------------------------------------------- #
#                                   path.nu                                    #
# ---------------------------------------------------------------------------- #

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
        if $path == '' {
            return ''
        } else if path == '/' {
            return $"(ansi purple)/(ansi reset)"
        }
        let type = if ($path | path exists) {
            $path | path type
        } else { null }
        let basename = $path | path basename
        # let basename_color = match $type {
        #     # 'file' => ([$path] | grid -c | lines first | str trim)
        #     'file' => 'default'
        #     'dir' => 'purple'
        #     'symlink' => 'red'
        #     null => 'yellow'
        # }
        # let basename = match $type {
        #     null => ($basename)
        #     _ => (^echo $basename | lscolors)
        # }
        let basename = $"(ansi purple)($basename)(ansi reset)"
        let parsed = $path | path parse | update parent {|p|
            $p.parent | path split | each {|e|
                $"(ansi green)($e)(ansi reset)"
            }
        }
        let result = if (try { ($parsed.parent | ansi strip | first) } catch { null }) == '/' {
            # $"(ansi cyan)/(ansi reset)" + ($parsed.parent | skip 1 | append ($"(ansi $basename_color)($basename)(ansi reset)") | path join | str replace -a (char path_sep) $"(ansi cyan)(char path_sep)(ansi reset)")
            $"(ansi cyan)/(ansi reset)" + ($parsed.parent | skip 1 | append $basename | path join | str replace -a (char path_sep) $"(ansi cyan)(char path_sep)(ansi reset)")
        } else {
            # $parsed.parent | append ($"(ansi $basename_color)($basename)(ansi reset)") | path join | str replace -a (char path_sep) $"(ansi cyan)(char path_sep)(ansi reset)"
            $parsed.parent | append $basename | path join | str replace -a (char path_sep) $"(ansi cyan)(char path_sep)(ansi reset)"
        }
        $result
    }
}
