
# ---------------------------------------------------------------------------- #
#                                    core.nu                                   #
# ---------------------------------------------------------------------------- #

use std null-device

# --------------------------------- commands --------------------------------- #

export def --env suppress [
    what: string = 'all'
    --environment(-e)
]: closure -> nothing {
    let closure = $in
    match $what {
        'a' | 'all' => (do --env=$environment $closure o+e> (null-device))
        'e' | 'err' | 'stderr' => (do --env=$environment $closure e> (null-device))
        'o' | 'out' | 'stdout' => (do --env=$environment $closure o> (null-device))
        _ => {
            error make {
                msg: "invalid argument"
                label: {
                    text: "valid arguments are: 'all', 'err', 'stderr', 'out', 'stdout'"
                    span: (metadata $what).span
                }
            }
        }
    }
}
