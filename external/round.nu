# ---------------------------------------------------------------------------- #
#                                   round.nu                                   #
# ---------------------------------------------------------------------------- #

use ../internal/utils.nu round_duration

export def "round duration" [unit?] {
    round_duration $unit
}

export def main [] {
    each { |e|
        if ($e | describe) == "duration" {
            $e | round duration
        } else {
            $e | math round
        }
    }
}
