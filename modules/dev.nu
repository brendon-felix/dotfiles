# ---------------------------------------------------------------------------- #
#                                    dev.nu                                    #
# ---------------------------------------------------------------------------- #

export def run [
    --watch(-w): string
] {
    let r = { nu ./run.nu }
    match $watch {
        null => { do $r }
        $w => { watch -g $w ./ $r }
    }
}

export def `watch cargo` [] {
    if not ('Cargo.toml' | path exists) {
        error make -u { msg: "Cargo.toml not found in current directory" }
    }
    if ('run.nu' | path exists) {
        watch -g *.rs ./ { try { nu run.nu } catch { print -n ""}; print (separator) }
    } else {
        watch -g *.rs ./ { try { cargo build --release } catch { print -n "" }; print (separator) }
    }
}
