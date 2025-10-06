
# ---------------------------------------------------------------------------- #
#                                   format.nu                                  #
# ---------------------------------------------------------------------------- #

use str.nu 'str remove'

export def `format hex` [
    --lower(-l)
    --width(-w): int
    --remove-prefix(-r)
]: int -> string {
    let format = if $lower { 'lowerhex' } else { 'upperhex' }
    $in | each {|e|
        mut e = $e | format number | get $format
        if $width != null {
            $e = $e | str remove '0x' | fill -a r -c '0' -w $width
            $e = '0x' + $e
        }
        if $remove_prefix {
            $e = $e | str remove '0x'
        }
        $e
    }
}

export def `format bin` [
    --width(-w): int
    --remove-prefix(-r)
]: int -> string {
    $in | each {|e|
        mut e = $e | format number | get binary
        if $width != null {
            $e = $e | str remove '0b' | fill -a r -c '0' -w $width
            $e = '0b' + $e
        }
        if $remove_prefix {
            $e = $e | str remove '0b'
        }
        $e
    }
}
