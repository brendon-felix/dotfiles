# ---------------------------------------------------------------------------- #
#                                    str.nu                                    #
# ---------------------------------------------------------------------------- #

export def `str remove` [
    substring: string
    --all(-a)
    --regex(-r)
    --multiline(-m)
] {
    each {|e| $e | str replace --all=$all --regex=$regex --multiline=$multiline $substring ''}
}