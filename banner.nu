# -------------------------------------------------------------------------- #
#                                  banner.nu                                 #
# -------------------------------------------------------------------------- #

# requires asciibar: `cargo install asciibar`

use std repeat

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
    # let memory_used_display_uncolored = $"($memory.used) \(($mem_used * 100 | math round --precision 0 )%\) ($mem_used_bar)"
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
        "          "
    ]

    let ellie = $ellie | each { |it| $"(ansi green)($it)(ansi reset)" }

    # let nushell = [
    # `                 _          _ _ `,
    # ` _ __  _   _ ___| |__   ___| | |`,
    # `| '_ \| | | / __| '_ \ / _ \ | |`,
    # `| | | | |_| \__ \ | | |  __/ | |`,
    # `|_| |_|\__,_|___/_| |_|\___|_|_|`,
    # `                                `,
    # ]
    
    # let nushell = $nushell | each { |it| $"(ansi black)($it)(ansi reset)" }

    let user = user_str

    let info = {
        version: (version_str),
        uptime: (uptime_str),
        memory: (mem_used_str)
    }
    print $" ($ellie.0)  ($user.user)"
    print $" ($ellie.1)  ($user.separator)"
    print $" ($ellie.2)  (ansi light_blue)version:(ansi reset) ($info.version)"
    print $" ($ellie.3)  (ansi light_blue)uptime:(ansi reset)  ($info.uptime)"
    print $" ($ellie.4)  (ansi light_blue)memory:(ansi reset)  ($info.memory)"

    # print $"           ($nushell.0)"
    # print $"($ellie.0) ($nushell.1)"
    # print $"($ellie.1) ($nushell.2)"
    # print $"($ellie.2) ($nushell.3)"
    # print $"($ellie.3) ($nushell.4)"
    # print $"           ($nushell.5)"
    # print $info

}

def main [] {
    print_banner
}