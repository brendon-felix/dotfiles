
# ---------------------------------------------------------------------------- #
#                                   status.nu                                  #
# ---------------------------------------------------------------------------- #

use print-utils.nu bar

def severity-bar [proportion] {
    let input = $in
    match $proportion {
        _ if $proportion < 0.6 => (bar -f green $proportion)
        _ if $proportion < 0.8 => (bar -f yellow $proportion)
        _ => (bar -f red $proportion)
    }
}

def severity [severity] {
    let input = $in
    match $severity {
        _ if $severity < 0.6 => ($input | ansi apply green)
        _ if $severity < 0.8 => ($input | ansi apply yellow)
        _ => ($input | ansi apply red)
    }
}

def disk_str [disk, --no-bar(-b)] {
    let disk_label = $"($disk.mount)"
    let amount_used = $disk.total - $disk.free
    let proportion_used = $amount_used / $disk.total
    let percent_used = ($proportion_used * 100 | math round --precision 0)
    mut disk_status = $"($amount_used) \(($percent_used)%\)" | severity $proportion_used
    if not $no_bar {
        let disk_bar = severity-bar $proportion_used
        $disk_status = $"($disk_bar) ($disk_status)"
    }
    $disk_status | severity $proportion_used
}

def memory_str [memory, --no-bar(-b)] {
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    mut memory_status = $"($memory.used) \(($percent_used)%\)" | severity $proportion_used
    if not $no_bar {
        let memory_bar = severity-bar $proportion_used
        $memory_status = $"($memory_bar) ($memory_status)"
    }
    $memory_status | severity $proportion_used
}

def mem_swap_str [memory, --no-bar(-b)] {
    let proportion_used = $memory.'swap used' / $memory.'swap total'
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    mut memory_status = $"($memory.'swap used') \(($percent_used)%\)" | severity $proportion_used
    if not $no_bar {
        let memory_bar = severity-bar $proportion_used
        $memory_status = $"($memory_bar) ($memory_status)"
    }
    $memory_status | severity $proportion_used
}

export def `status disks` [--no-bar(-b)] {
    let disks = (sys disks)
    $disks | each { |disk| {$disk.mount: (disk_str --no-bar=($no_bar) $disk)} } | into record
}

export def `status memory` [--no-bar(-b)] {
    let memory = (sys mem)
    {
        RAM: (memory_str $memory --no-bar=($no_bar))
        Swap: (mem_swap_str $memory --no-bar=($no_bar))
    }
}

export alias memory = status memory
export alias ram = status memory
export alias disks = status disks

