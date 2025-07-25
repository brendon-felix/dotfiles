
# ---------------------------------------------------------------------------- #
#                                  monitor.nu                                  #
# ---------------------------------------------------------------------------- #

def monitor [--interval(-i): duration = 1sec]: closure -> nothing {
    clear
    let task = $in
    let loading = [
        "⠇   ",
        "⠋   ",
        " ⠉  ",
        "  ⠉ ",
        "   ⠙",
        "   ⠸",
        "   ⠴",
        "  ⣀ ",
        " ⣀  ",
        "⠦   ",
    ] | ansi apply cyan
    let loading_len = $loading | length
    # mut cursor_start = cursor position
    mut term_size = term size
    let start_time = date now
    cursor off
    loop {
        let task_start_time = date now
        try {
            let result = do $task
            print $result
            while (((date now) - $task_start_time) < $interval) {
                let i = ((((date now) - $start_time) mod $interval) / $interval) * $loading_len | math floor
                let line = $"($loading | get $i)" | fill -a r -w (term size).columns
                print -n $"($line)\r"
            }
            # if (term size) != $term_size {
            #     $term_size = term size
            #     erase
            #     $cursor_start = cursor position
            # } else {
            #     cursor move-to $cursor_start
            # }
            if (term size) != $term_size {
                $term_size = term size
                clear
            }
            cursor home
        } catch {
            break;
        }
    }
    cursor on
}

export def `monitor disk` [--no-bar(-b), --all(-a)] {
    let task = match $all {
        true => { status disks --no-bar=($no_bar) }
        false => {
            let disks = sys disks | upsert display {|e| $"($e.mount) \(($e.device)\)"}
            let disk_choice = ($disks | input list -d display)
            { (status disks --no-bar=($no_bar)) | select $disk_choice.mount }
        }
    }
    $task | monitor
}

export def `monitor memory` [--no-bar(-b), --all(-a)] {
    let task = match $all {
        true => { status memory --no-bar=($no_bar) }
        false => {
            let mem_choice = ['RAM' 'Swap'] | input list
            { status memory --no-bar=($no_bar) | select $mem_choice }
        }
    }
    $task | monitor
}

export def `monitor ram` [--no-bar(-b)] {
    { status memory --no-bar=($no_bar) | select RAM } | monitor
}

export def `monitor banner` [] {
    { print banner } | monitor
}

