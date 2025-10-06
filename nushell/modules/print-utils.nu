
# ---------------------------------------------------------------------------- #
#                                print-utils.nu                                #
# ---------------------------------------------------------------------------- #

use std null-device

export def bar [
    value: float
    --length(-l): int = 12
    --fg-color(-f): any = '#DCDFE4'
    --bg-color(-b): any = '#505050'
    # --attr(-a): string
] {
    let bar = ^bar -l $length $value
    let ansi_color = {fg: $fg_color, bg: $bg_color}
    $"(ansi -e $ansi_color)($bar)(ansi reset)"
}

export def separator [
    length?: int
    --alignment(-a): string = 'c'
] {
    let input = match $in {
        null => ""
        _ => {match $alignment {
            'l' => $"($in) "
            'c' | 'm' | 'cr' | 'mr' => $" ($in) "
            'r' => $" ($in)"
        }}
    }
    let length = match $length {
        null => (term size).columns
        _ => $length
    }
    $input | fill -a $alignment -c '─' -w $length
}

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
