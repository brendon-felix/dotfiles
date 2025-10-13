
# ---------------------------------------------------------------------------- #
#                                   status.nu                                  #
# ---------------------------------------------------------------------------- #

use round.nu 'round duration'
use paint.nu *
use print-utils.nu bar

# def disk_str [disk, --no-bar(-b)] {
#     let disk_label = $"($disk.mount)"
#     let amount_used = $disk.total - $disk.free
#     let proportion_used = $amount_used / $disk.total
#     let percent_used = ($proportion_used * 100 | math round --precision 0)
#     mut disk_status = $"($amount_used) \(($percent_used)%\)" | severity $proportion_used
#     if not $no_bar {
#         let disk_bar = severity-bar $proportion_used
#         $disk_status = $"($disk_bar) ($disk_status)"
#     }
#     $disk_status | severity $proportion_used
# }

# export def `status disks` [--no-bar(-b)] {
#     let disks = (sys disks)
#     $disks | each { |disk| {$disk.mount: (disk_str --no-bar=($no_bar) $disk)} } | into record
# }

export def `status startup` [--icon(-i)] {
    let startup_time = $nu.startup-time | round duration ms
    let startup = match $startup_time {
        $t if $t < 100ms => ($startup_time | paint green)
        $t if $t < 250ms => ($startup_time | paint yellow)
        $t => ($startup_time  | paint red)
    }
    if $icon { $"(char -u f520)  " + $startup } else { $startup }
}

export def `status uptime` [--icon(-i)] {
    let uptime_time = sys host | get uptime
    let uptime = match $uptime_time {
        $t if $t < 1day => ($t | round duration min | paint green)
        $t if $t < 1wk => ($t | round duration hr | paint yellow)
        $t => ($t | round duration day | paint red)
    }
    if $icon { $"(char -u f43a)  " + $uptime } else { $uptime }
}

export def `status memory` [
    --icon(-i)
    --bar(-b)
] {
    let memory = sys mem
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round | into int)
    let color = match $percent_used {
        $p if $p < 60 => 'green'
        $p if $p < 80 => 'yellow'
        _ => 'red'
    }
    let memory_status = $"($memory.used) \(($percent_used)%\)"
    let memory_status = if $bar {
        let memory_bar = bar $proportion_used -f $color
        $"($memory_bar) ($memory_status | paint $color)"
    } else {
        $memory_status | paint $color
    }
    if $icon { $"(char -u efc5)  " + $memory_status } else { $memory_status }
}

export def `status disks` [
    --icon(-i)
    --bar(-b)
] {
    sys disks | each {|disk|
        let disk_label = $"($disk.mount)"
        let amount_used = $disk.total - $disk.free
        let proportion_used = $amount_used / $disk.total
        let percent_used = ($proportion_used * 100 | math round | into int)
        let disk_status = $"($amount_used) \(($percent_used)%\)"
        let color = match $percent_used {
            $p if $p < 60 => 'green'
            $p if $p < 80 => 'yellow'
            _ => 'red'
        }
        let disk_status = if $bar {
            let disk_bar = bar $proportion_used -f $color
            $"($disk_bar) ($disk_status | paint $color)"
        } else {
            $disk_status | paint $color
        }
        {mount: $disk.mount, status: (if $icon { $"(char -u f0a0)  " + $disk_status } else { $disk_status }) }
    }
}

export def main [
    --icons(-i)
    --bar(-b)
    --english(-e)
] {
    if $english {
        let startup = status startup
        let uptime = status uptime
        let memory = status memory
        let disk = status disks | first
        [
            $"It took ($startup) to start this shell."
            $"This system has been up for ($uptime)."
            $"There is ($memory) of memory in use."
            $"The ($disk.mount | paint cyan) drive is ($disk.status) full."
        ]
    } else {
        let startup = status startup --icon=$icons
        let uptime = status uptime --icon=$icons
        let memory = status memory --icon=$icons --bar=$bar
        let disk = status disks --icon=$icons --bar=$bar | first
        {
            startup: $startup
            uptime: $uptime
            memory: $memory
            disk: $disk.status
        }
    }
}
