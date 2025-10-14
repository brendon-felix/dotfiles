
# ---------------------------------------------------------------------------- #
#                                   round.nu                                   #
# ---------------------------------------------------------------------------- #

def get-unit [
    duration: duration
    whole: bool
]: nothing -> duration {
    match $duration {
        $d if ($d < 1us) and $whole  => 1ns
        $d if ($d < 1ms) and $whole  => 1us
        $d if ($d < 1ms)               => 1ns
        $d if ($d < 1sec) and $whole => 1ms
        $d if ($d < 1sec)              => 1us
        $d if ($d < 1min) and $whole => 1sec
        $d if ($d < 1min)              => 1ms
        $d if ($d < 1hr) and $whole  => 1min
        $d if ($d < 1hr)               => 1sec
        $d if ($d < 1day) and $whole => 1hr
        $d if ($d < 1day)              => 1min
        $d if ($d < 1wk) and $whole  => 1day
        $d if ($d < 1wk)               => 1hr
        _                              => 1day
    }
}

export def "round duration" [
    unit?: string # ns, us, ms, sec, min, hr, day, wk
    --whole(-w) # round to whole unit if no unit specified
]: duration -> duration {
    each { |e|
        let unit_time = match $unit {
            ns => 1ns
            us => 1us
            ms => 1ms
            sec => 1sec
            min => 1min
            hr => 1hr
            day => 1day
            wk => 1wk
            null => { get-unit $e $whole }
            _ => { error make -u {msg: $"Invalid unit: ($unit)"} }
        }
        let rounded_ns = ($e / $unit_time | math round) * $unit_time
        $rounded_ns | into duration
    }
}
