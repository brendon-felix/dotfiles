# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

# requires asciibar: `cargo install asciibar`

use round.nu 'round duration'
use status.nu 'status memory'

def startup_str [] {
    let startup_time = ($nu.startup-time | round duration ms)
    match $startup_time {
        _ if $startup_time == 0sec => null
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


def header_str [] {
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

def user_str [] {
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

def print_banner_header [] {
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

def print_banner_info [] {
    let startup = startup_str
    let uptime = uptime_str
    let memory = status memory -b
    if $startup != null {
        print $" It took ($startup) to start this shell."
    }
    print $" This system has been up for ($uptime)."
    print $" ($memory.RAM) of memory is in use."
    print ""
}

export def main [] {
    print_banner_header
    print_banner_info
}
