# ---------------------------------------------------------------------------- #
#                                   utils.nu                                   #
# ---------------------------------------------------------------------------- #

# This file contains utility functions for other scripts and NOT for direct use


# use ../external/round.nu *

# ---------------------------------- aliases --------------------------------- #

export alias bar = asciibar --empty '░' --half-filled '▓' --filled '█' --length 12

# ----------------------------------- apps ----------------------------------- #

 export def start_app [app_name] {
    let shortcut_filename = $"($app_name).lnk"
    let possible_paths = [
        ([$env.APPDATA, `Microsoft\Windows\Start Menu\Programs`, $shortcut_filename] | path join),
        ([$env.APPDATA, `Microsoft\Windows\Start Menu\Programs`, $app_name, $shortcut_filename] | path join),
        ([$env.ProgramData, `Microsoft\Windows\Start Menu\Programs`, $shortcut_filename] | path join),
        ([$env.ProgramData, `Microsoft\Windows\Start Menu\Programs`, $app_name, $shortcut_filename] | path join)
    ]
    mut result: any = null
    for $path in $possible_paths {
        if ($path | path exists) {
            $result = $path
        }
    }
    if $result == null {
        error make {
            msg: $"Shortcut for ($app_name) not found in any of the expected paths.",
            label: {
                text: "Application not found"
                span: (metadata $app_name).span
            }
        }
    } else {
        start $result
    }
}

# ----------------------------------- misc ----------------------------------- #
export def round_duration [unit?] {
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
                    _ if ($e mod 1day == 0sec) => 1wk,
                    _ if ($e mod 1hr == 0sec) => 1day,
                    _ if ($e mod 1min == 0sec) => 1hr,
                    _ if ($e mod 1sec == 0sec) => 1min,
                    _ if ($e mod 1ms == 0sec) => 1sec,
                    _ if ($e mod 1us == 0sec) => 1ms,
                    _ if ($e mod 1ns == 0sec) => 1us,
                    _ => 1ns
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

export def separator [--alignment(-a): string = 'c'] {
    let input = match $in {
        null => ""
        _ => {match $alignment {
            'l' => $"($in) "
            'c' | 'm' | 'cr' | 'mr' => $" ($in) "
            'r' => $" ($in)"
        }}
    }
    $input | fill -a $alignment -c '─' -w (term size).columns
}

# ----------------------------------- info ----------------------------------- #



