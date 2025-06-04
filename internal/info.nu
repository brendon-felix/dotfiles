use utils.nu [bar round_duration]


# ---------------------------------- memory ---------------------------------- #

export def memory_str [] {
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

# ----------------------------------- disks ---------------------------------- #

export def disks_str [disk] {
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

export def disks_strs [] {
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



# -------------------------------- system info ------------------------------- #
export def startup_str [] {
    let startup_time = ($nu.startup-time | round_duration ms)
    match $startup_time {
        _ if $startup_time == 0sec => null
        _ if $startup_time < 100ms => $"(ansi green)($startup_time)(ansi reset)"
        _ if $startup_time < 500ms => $"(ansi yellow)($startup_time)(ansi reset)"
        _ => $"(ansi red)($startup_time)(ansi reset)"
    }
}

export def uptime_str [] {
    let uptime = (sys host).uptime
    # let uptime = (2wk + 3day + 4hr + 5min + 6sec)
    match $uptime {
        _ if $uptime < 1day => $"(ansi green)($uptime | round_duration min)(ansi reset)"
        _ if $uptime < 1wk => $"(ansi yellow)($uptime | round_duration hr)(ansi reset)"
        _ => $"(ansi red)($uptime | round_duration day)(ansi reset)"
    }
}


export def header_str [] {
    let installed_version_str = $"v(version | get version)"
    let header_start = "Nushell "

    # calculate before coloring
    let length = ($installed_version_str | str length) + ($header_start | str length)
    let separator = ("" | fill -c '─' -w $length | str join)

    let header_start = $"(ansi green)($header_start)(ansi reset)"
    let installed_version_str = match (version check).current {
        true => $"(ansi green)($installed_version_str)(ansi reset)"
        false => $"(ansi yellow)($installed_version_str)(ansi reset)" # yellow when outdated
    }

    {
        header: $"($header_start)($installed_version_str)",
        separator: $separator,
    }
}

export def user_str [] {
    # let computer_name = ($env.COMPUTERNAME | str trim) # 'KEPLER'
    let host_name = (sys host | get hostname) # 'kepler'
    let username = ($env.USERNAME | str trim) # 'felixb'
    let length = ($host_name | str length) + 1 + ($username | str length)
    let separator = ("" | fill -c '─' -w $length | str join)
    let my_str = $"(ansi light_purple)($username)(ansi reset)@(ansi light_purple)($host_name)(ansi reset)"
    {
        separator: $separator,
        user: $my_str
    }
}
