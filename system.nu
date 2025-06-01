use misc.nu bar

const UPDATE_INTERVAL = 200ms

# ---------------------------------- memory ---------------------------------- #

def memory_str [] {
    let memory = (sys mem)
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    let memory_bar = bar $proportion_used
    let memory_text = $"($memory.used) \(($percent_used)%\)"
    match $proportion_used {
        _ if $proportion_used < 0.6 => {
            text: $"(ansi green)($memory_text)(ansi reset)"
            bar: $"(ansi green)($memory_bar)(ansi reset)"
        }
        _ if $proportion_used < 0.8 => {
            text: $"(ansi yellow)($memory_text)(ansi reset)"
            bar: $"(ansi yellow)($memory_bar)(ansi reset)"
        }
        _ => {
            text: $"(ansi red)($memory_text)(ansi reset)"
            bar: $"(ansi red)($memory_bar)(ansi reset)"
        }
    }
}

export def "memory monitor" [] {
    # let loading = ["|", "/", "-", "\\"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
    # let loading = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
    let loading = ["⠋", "⠙", "⠸", "⠴", "⠦", "⠇"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
    loop {
        let memory = memory_str
        for e in $loading {
            print -n $"  RAM: ($memory.bar) ($memory.text) ($e)\r"
            sleep $UPDATE_INTERVAL
        }
    }
}

export def memory [] {
    let memory = memory_str
    $"RAM: ($memory.bar) ($memory.text)"
}


# ----------------------------------- disks ---------------------------------- #

def disks_str [disk] {
    let disks = (sys disks)
    $disks | each { |disk| 
        # let disk_label = $"($disk.device) \(($disk.mount)\)"
        let disk_label = $"($disk.mount)"
        let amount_used = $disk.total - $disk.free
        let proportion_used = $amount_used / $disk.total
        let percent_used = ($proportion_used * 100 | math round --precision 0)
        let disk_bar = bar $proportion_used
        let disk_status = $"($disk_bar) ($amount_used) \(($percent_used)%\)"
        match $proportion_used {
            _ if $proportion_used < 0.6 => $"($disk_label): (ansi green)($disk_status)(ansi reset)"
            _ if $proportion_used < 0.8 => $"($disk_label): (ansi yellow)($disk_status)(ansi reset)"
            _ => $"($disk_label): (ansi red)($disk_status)(ansi reset)"
        }
    }
}

def disks_strs [] {
    let disks = (sys disks)
    $disks | each { |disk| 
        # let disk_label = $"($disk.device) \(($disk.mount)\)"
        let disk_label = $"($disk.mount)"
        let amount_used = $disk.total - $disk.free
        let proportion_used = $amount_used / $disk.total
        let percent_used = ($proportion_used * 100 | math round --precision 0)
        let disk_bar = bar $proportion_used
        let disk_status = $"($disk_bar) ($amount_used) \(($percent_used)%\)"
        match $proportion_used {
            _ if $proportion_used < 0.6 => $"($disk_label): (ansi green)($disk_status)(ansi reset)"
            _ if $proportion_used < 0.8 => $"($disk_label): (ansi yellow)($disk_status)(ansi reset)"
            _ => $"($disk_label): (ansi red)($disk_status)(ansi reset)"
        }
    }
}

export def "disk monitor" [] {
    let disk_choice = (sys disks | select device mount | input list).mount
    

    let loading = ["⠋", "⠙", "⠸", "⠴", "⠦", "⠇"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
    loop {
        let disk = (sys disks | where mount == $disk_choice | first)
        let disk_label = $"($disk.mount)"
        let amount_used = $disk.total - $disk.free
        let proportion_used = $amount_used / $disk.total
        let percent_used = ($proportion_used * 100 | math round --precision 0)
        let disk_bar = bar $proportion_used
        let disk_status = $"($disk_bar) ($amount_used) \(($percent_used)%\)"
        let disk_str = match $proportion_used {
            _ if $proportion_used < 0.6 => $"($disk_label): (ansi green)($disk_status)(ansi reset)"
            _ if $proportion_used < 0.8 => $"($disk_label): (ansi yellow)($disk_status)(ansi reset)"
            _ => $"($disk_label): (ansi red)($disk_status)(ansi reset)"
        }
        for e in $loading {
            print -n $"  ($disk_str) ($e)\r"
            sleep $UPDATE_INTERVAL
        }
    }
}

export def disks [] {
    # let disk_info = disks_strs
    # for disk in $disk_info {
    #     print -n $"($disk)\n"
    # }

    disks_strs
}

