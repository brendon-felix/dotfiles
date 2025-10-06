
# ---------------------------------------------------------------------------- #
#                                      rest.nu                                 #
# ---------------------------------------------------------------------------- #

export def show [file: glob] {
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
