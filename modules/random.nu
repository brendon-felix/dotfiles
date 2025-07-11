
# ---------------------------------------------------------------------------- #
#                                   random.nu                                  #
# ---------------------------------------------------------------------------- #

export def `random color` [
    --hsv(-h)
    --dark(-d)
    --light(-l)
    --gray(-g)
] {
    if $dark and $light {
        error make -u { msg: "Cannot specify both --dark (-d) and --light (-l)" }
    }
    if not $hsv {
        match $gray {
            true => {
                let range = match _ {
                    _ if $dark => 0..95
                    _ if $light => 160..255
                    _ => 0..255
                }
                let v = random int $range
                {r: $v, g: $v, b: $v}
            }
            false => {
                let range = match _ {
                    _ if $dark => {r: 0..100, g: 0..100, b: 0..100}
                    _ if $light => {r: 128..255, g: 128..255, b: 128..255}
                    _ => {r: 0..255, g: 0..255, b: 0..255}
                }
                {
                    r: (random int $range.r)
                    g: (random int $range.g)
                    b: (random int $range.b)
                }
            }
        }
    } else {
        match $gray {
            true => {
                let range = match _ {
                    _ if $dark => 0.0..<0.3
                    _ if $light => 0.75..<1.0
                    _ => 0.0..<1.0
                }
                let v = random float $range
                {h: 0, s: 0.0, v: $v}
            }
            false => {
                let range = match _ {
                    _ if $dark => {h: 0..<360, s: 0.25..<1.0, v: 0.0..<0.4}
                    _ if $light => {h: 0..<360, s: 0.25..<1.0, v: 0.75..<1.0}
                    _ => {h: 0..<360, s: 0.0..<1.0, v: 0.0..<1.0}
                }
                {
                    h: (random int $range.h)
                    s: (random float $range.s)
                    v: (random float $range.v)
                }
            }
        }
    }
}

