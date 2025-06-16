# ---------------------------------------------------------------------------- #
#                                   status.nu                                  #
# ---------------------------------------------------------------------------- #

use print-utils.nu bar
use color.nu 'color apply'

def severity [severity] {
    let input = $in
    match $severity {
        _ if $severity < 0.6 => ($input | color apply green)
        _ if $severity < 0.8 => ($input | color apply yellow)
        _ => ($input | color apply red)
    }
}

def disk_str [disk, --no-bar(-b)] {
    let disk_label = $"($disk.mount)"
    let amount_used = $disk.total - $disk.free
    let proportion_used = $amount_used / $disk.total
    let percent_used = ($proportion_used * 100 | math round --precision 0)
    mut disk_status = $"($amount_used) \(($percent_used)%\)"
    if not $no_bar {
        let disk_bar = bar $proportion_used
        $disk_status = $"($disk_bar) ($disk_status)"
    }
    $disk_status | severity $proportion_used
}

def memory_str [--no-bar(-b)] {
    let memory = (sys mem)
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    mut memory_status = $"($memory.used) \(($percent_used)%\)"
    if not $no_bar {
        let memory_bar = bar $proportion_used
        $memory_status = $"($memory_bar) ($memory_status)"
    }
    $memory_status | severity $proportion_used
}

export def `status disks` [--no-bar(-b)] {
    let disks = (sys disks)
    $disks | each { |disk| {$disk.mount: (disk_str --no-bar=($no_bar) $disk)} } | into record
}

export def `status memory` [--no-bar(-b)] {
    {RAM: (memory_str --no-bar=($no_bar))}
}

export alias memory = status memory
export alias ram = status memory
export alias disks = status disks