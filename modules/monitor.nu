# ---------------------------------------------------------------------------- #
#                                  monitor.nu                                  #
# ---------------------------------------------------------------------------- #

use status.nu *
use ansi.nu [color 'cursor off']

const UPDATE_INTERVAL = 200ms

export def "monitor disks" [--no-bar(-b)] {
    let disk_choice = (sys disks | select device mount | input list).mount
    let loading = ["⠋", "⠙", "⠸", "⠴", "⠦", "⠇"] | color cyan
    cursor off
    loop {
        let disk_status = (status disks --no-bar=($no_bar)) | get $disk_choice
        for e in $loading {
            print -n $"($disk_choice): ($disk_status) ($e)\r"
            sleep $UPDATE_INTERVAL
        }
    }
}

export def "monitor memory" [--no-bar(-b)] {
    let loading = ["⠋", "⠙", "⠸", "⠴", "⠦", "⠇"] | color cyan
    cursor off
    loop {
        let memory = (status memory --no-bar=($no_bar))
        for e in $loading {
            print -n $"RAM: ($memory.RAM) ($e)\r"
            sleep $UPDATE_INTERVAL
        }
    }
}