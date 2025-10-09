# ---------------------------------------------------------------------------- #
#                                   jobs.nu                                    #
# ---------------------------------------------------------------------------- #

export def --env `job try-recv` [
    --tag: int
] {
    try { job recv --tag=$tag --timeout 0sec } catch { null }
}

export alias `job recv-builtin` = job recv

export def `job recv` [
    --tag: int
    --timeout(-t): duration
    --all(-a)
] {
    let timeout = if $all { 0sec } else { $timeout }
    let cmd = match $tag {
        null => { match $timeout {
            null => {|| job recv-builtin }
            _ => {|| job recv-builtin --timeout=$timeout }
        }}
        $tag => { match $timeout {
            null => {|| job recv-builtin --tag=$tag }
            _ => {|| job recv-builtin --tag=$tag --timeout=$timeout }
        }}
    }
    if $all {
        mut messages = []
        loop { try { $messages = $messages | append (do $cmd) } catch { break } }
        $messages
    } else {
        do $cmd
    }
}
