# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

# requires asciibar: `cargo install asciibar`

use ../internal/utils.nu round_duration
use ../internal/info.nu [startup_str uptime_str user_str header_str]
use ./status.nu memory


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
    let memory = memory
    if $startup != null {
        print $" It took ($startup) to start this shell."
    }
    print $" This system has been up for ($uptime)."
    print $" ($memory)"
    print ""
}

export def main [] {
    print_banner_header
    print_banner_info
}
