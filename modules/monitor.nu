# ---------------------------------------------------------------------------- #
#                                  monitor.nu                                  #
# ---------------------------------------------------------------------------- #

use status.nu *
use cursor.nu 'cursor off'

const UPDATE_INTERVAL = 200ms

export def "monitor disks" [--bar(-b)] {
    let disk_choice = (sys disks | select device mount | input list).mount
    let loading = ["⠋", "⠙", "⠸", "⠴", "⠦", "⠇"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
    cursor off
    loop {
        let disk_status = (status disks --bar=($bar)) | get $disk_choice
        for e in $loading {
            print -n $"($disk_choice): ($disk_status) ($e)\r"
            sleep $UPDATE_INTERVAL
        }
    }
}

export def "monitor memory" [--bar(-b)] {
    let loading = ["⠋", "⠙", "⠸", "⠴", "⠦", "⠇"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
    cursor off
    loop {
        let memory = (status memory --bar=($bar))
        for e in $loading {
            print -n $"RAM: ($memory.RAM) ($e)\r"
            sleep $UPDATE_INTERVAL
        }
    }
}