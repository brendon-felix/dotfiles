# -------------------------------------------------------------------------- #
#                                  banner.nu                                 #
# -------------------------------------------------------------------------- #

# requires asciibar: `cargo install asciibar`

def get_user_display [] {
    # let computer_name = ($env.COMPUTERNAME | str trim) # 'KEPLER'
    let host_name = (sys host | get hostname) # 'kepler'
    let username = ($env.USERNAME | str trim) # 'felixb'
    $"(ansi light_purple)($username)(ansi reset)@(ansi light_purple)($host_name)(ansi reset)"
}

def version_str [] {
    match (version check).current {
        true => $"(ansi green)v(version | get version) \(latest\)(ansi reset)"
        false => $"(ansi yellow)v(version | get version)(ansi reset) \(update available\)(ansi reset)"
    }
}

def uptime_str [] {

    let uptime = (sys host).uptime
    # let uptime = 8day + 2hr + 43min + 31sec
    # let uptime = 0.85day
    let uptime_display_uncolored = ($uptime)
    match $uptime {
        _ if $uptime < 1day => $"(ansi green)($uptime_display_uncolored)(ansi reset)"
        _ if $uptime < 1wk => $"(ansi yellow)($uptime_display_uncolored)(ansi reset)"
        _ => $"(ansi red)($uptime_display_uncolored)(ansi reset)"
    }
}

def mem_used_str [] {
    let memory = (sys mem)
    let mem_used = $memory.used / $memory.total
    let mem_used_bar = (asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $mem_used)
    let memory_used_display_uncolored = $"($mem_used_bar) ($memory.used) \(($mem_used * 100 | math round --precision 0 )%\)"
    match $mem_used {
        _ if $mem_used < 0.6 => $"(ansi green)($memory_used_display_uncolored)(ansi reset)"
        _ if $mem_used < 0.8 => $"(ansi yellow)($memory_used_display_uncolored)(ansi reset)"
        _ => $"(ansi red)($memory_used_display_uncolored)(ansi reset)"
    }
}

def print_banner [] {
    let ellie = [
        "     __  ,"
        " .--()°'.'"
        "'|, . ,'  "
        ' !_-(_\   '
    ]
    
    let info = [
        # $"(get_user_display)"
        $"(ansi light_blue)version:(ansi reset) (version_str)"
        $"(ansi light_blue)uptime:(ansi reset)  (uptime_str)"
        $"(ansi light_blue)memory:(ansi reset)  (mem_used_str)"
    ]

    # print $"Welcome to (ansi green)Nushell(ansi reset)"
    print $"\n(get_user_display)"
    print $" (ansi green)($ellie.0)(ansi reset)"
    print $" (ansi green)($ellie.1)(ansi reset)  ($info.0)"
    print $" (ansi green)($ellie.2)(ansi reset)  ($info.1)"
    print $" (ansi green)($ellie.3)(ansi reset)  ($info.2)\n"
    # 
}

def main [] {
    print_banner
}