
# ---------------------------------------------------------------------------- #
#                                      rest.nu                                 #
# ---------------------------------------------------------------------------- #

export def show [file] {
    open -r $file | highlight
}

export alias tree = tree.exe

export def `update commands` [] {
    cd ~/Projects/nushell-scripts/
    let modules = ls modules | get name
    open everything.nu.base | save -f everything.nu
    for module in $modules {
        open $module | save -a everything.nu
    }
}

export def `path stem-append` [
    s: string
    --separator(-s): string = '_'
] {
    $in | each {|e|
        mut parsed = $e | path parse
        $parsed.stem += $separator + $s
        $parsed | path join
    }
}
