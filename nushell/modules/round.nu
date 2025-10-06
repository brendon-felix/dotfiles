
# ---------------------------------------------------------------------------- #
#                                   round.nu                                   #
# ---------------------------------------------------------------------------- #

export def "round duration" [unit?]: duration -> duration {
    each { |e|
        let unit_time = match $unit {
            ns => 1ns,
            us => 1us,
            ms => 1ms,
            sec => 1sec,
            min => 1min,
            hr => 1hr,
            day => 1day,
            wk => 1wk,
            null => {
                match $e {
                    # _ if ($e mod 1day == 0sec) => 1wk,
                    # _ if ($e mod 1hr == 0sec) => 1day,
                    # _ if ($e mod 1min == 0sec) => 1hr,
                    # _ if ($e mod 1sec == 0sec) => 1min,
                    # _ if ($e mod 1ms == 0sec) => 1sec,
                    # _ if ($e mod 1us == 0sec) => 1ms,
                    # _ if ($e mod 1ns == 0sec) => 1us,
                    # _ => 1ns
                    _ if ($e < 1ms) => 1ns,
                    _ if ($e < 1sec) => 1us,
                    _ if ($e < 1min) => 1ms,
                    _ if ($e < 1hr) => 1sec,
                    _ if ($e < 1day) => 1min,
                    _ if ($e < 1wk) => 1hr,
                    _ => 1day
                }
            }
            _ => {
                throw "Invalid unit: $unit"
            }
        }
        let rounded_ns = ($e / $unit_time | math round) * $unit_time
        $rounded_ns | into duration
    }
}
