# ---------------------------------------------------------------------------- #
#                                  monitor.nu                                  #
# ---------------------------------------------------------------------------- #

use status.nu *
use ansi.nu ['cursor off' 'erase right']
use color.nu 'color apply'

use debug.nu *

const UPDATE_INTERVAL = 200ms

def monitor [] {
    let command = $in
    let loading = ["⠋", "⠙", "⠸", "⠴", "⠦", "⠇"] | color apply cyan
    cursor off
    loop {
        let status = do $command
        for e in $loading {
            # erase right
            print -n $"($status) ($e)\r"
            sleep $UPDATE_INTERVAL
        }
    }
}

export def `monitor disk` [--no-bar(-b)] {
    let disks = sys disks | upsert display {|e| $"($e.mount) \(($e.device)\)"}
    let disk_choice = ($disks | input list -d display)
    {$"($disk_choice.mount): ((status disks --no-bar=($no_bar)) | get $disk_choice.mount)"} | monitor
}

export def `monitor memory` [--no-bar(-b)] {
    let mem_choice = ['RAM' 'Swap'] | input list
    {$"($mem_choice): (status memory | get $mem_choice)"} | monitor
}
