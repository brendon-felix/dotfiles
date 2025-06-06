# ---------------------------------------------------------------------------- #
#                                   status.nu                                  #
# ---------------------------------------------------------------------------- #

use print-utils.nu bar

def severity [severity] {
    let input = $in
    match $severity {
        _ if $severity < 0.6 => $"(ansi green)($input)(ansi reset)"
        _ if $severity < 0.8 => $"(ansi yellow)($input)(ansi reset)"
        _ => $"(ansi red)($input)(ansi reset)"
    }
}

def disk_str [disk, --bar(-b)] {
    let disk_label = $"($disk.mount)"
    let amount_used = $disk.total - $disk.free
    let proportion_used = $amount_used / $disk.total
    let percent_used = ($proportion_used * 100 | math round --precision 0)
    mut disk_status = $"($amount_used) \(($percent_used)%\)"
    if $bar {
        let disk_bar = bar $proportion_used
        $disk_status = $"($disk_bar) ($disk_status)"
    }
    $disk_status | severity $proportion_used
}

def memory_str [--bar(-b)] {
    let memory = (sys mem)
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    mut memory_status = $"($memory.used) \(($percent_used)%\)"
    if $bar {
        let memory_bar = bar $proportion_used
        $memory_status = $"($memory_bar) ($memory_status)"
    }
    $memory_status | severity $proportion_used
}

export def "status disks" [--bar(-b)] {
    let disks = (sys disks)
    $disks | each { |disk| {$disk.mount: (disk_str --bar=($bar) $disk)} } | into record
}

export def "status memory" [--bar(-b)] {
    {RAM: (memory_str --bar=($bar))}
}
