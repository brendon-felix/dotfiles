# -------------------------------------------------------------------------- #
#                                  banner.nu                                 #
# -------------------------------------------------------------------------- #

# requires asciibar: `cargo install asciibar`

use std repeat
use round.nu *

def header_str [] {
    let installed_version_str = $"v(version | get version)"
    let header_start = "Nushell "

    # calculate before coloring
    let length = ($installed_version_str | str length) + ($header_start | str length)
    let separator = ('─' | repeat $length | str join)

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

def user_str [] {
    # let computer_name = ($env.COMPUTERNAME | str trim) # 'KEPLER'
    let host_name = (sys host | get hostname) # 'kepler'
    let username = ($env.USERNAME | str trim) # 'felixb'
    let length = ($host_name | str length) + 1 + ($username | str length)
    let separator = ('─' | repeat $length | str join)
    let my_str = $"(ansi light_purple)($username)(ansi reset)@(ansi light_purple)($host_name)(ansi reset)"
    {
        separator: $separator,
        user: $my_str
    }
}

def startup_str [] {
    let startup_time = ($nu.startup-time | round duration ms)
    match $startup_time {
        _ if $startup_time < 100ms => $"(ansi green)($startup_time)(ansi reset)"
        _ if $startup_time < 500ms => $"(ansi yellow)($startup_time)(ansi reset)"
        _ => $"(ansi red)($startup_time)(ansi reset)"
    }
}

def uptime_str [] {
    let uptime = (sys host).uptime
    # let uptime = (2wk + 3day + 4hr + 5min + 6sec)
    match $uptime {
        _ if $uptime < 1day => $"(ansi green)($uptime | round duration min)(ansi reset)"
        _ if $uptime < 1wk => $"(ansi yellow)($uptime | round duration hr)(ansi reset)"
        _ => $"(ansi red)($uptime | round duration day)(ansi reset)"
    }
}

def memory_str [] {
    let memory = (sys mem)
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    let memory_bar = (asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $proportion_used)
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

def print_banner [] {
    let ellie = [
        "     __  ,"
        " .--()°'.'"
        "'|, . ,'  "
        ' !_-(_\   '
        "          "
    ]
    let ellie = $ellie | each { |it| $"(ansi green)($it)(ansi reset)" }

    let user = user_str
    let header = header_str
    let header_lines = [
        "",
        $header.header,
        $header.separator,
        $user.user,
        "",
    ]

    for line in ($ellie | zip $header_lines) {
        print $" ($line.0)  ($line.1)"
    }
}

def print_info [] {
    let startup = startup_str
    let uptime = uptime_str
    let memory = memory_str
    print $" It took ($startup) to start this shell."
    print $" This system has been up for ($uptime)."
    print $" RAM: ($memory.bar) ($memory.text)"
    print ""
}

export def "main" [] {
    print_banner
    print_info
}
