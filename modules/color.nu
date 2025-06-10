# ---------------------------------------------------------------------------- #
#                                   color.nu                                   #
# ---------------------------------------------------------------------------- #


export def "color green" []: string -> string {
    $"(ansi reset)(ansi green)($in)(ansi reset)"
}

export def "color red" []: string -> string {
    $"(ansi reset)(ansi red)($in)(ansi reset)"
}

export def "color yellow" []: string -> string {
    $"(ansi reset)(ansi yellow)($in)(ansi reset)"
}

export def "color cyan" []: string -> string {
    $"(ansi reset)(ansi cyan)($in)(ansi reset)"
}

export def "color blue" []: string -> string {
    $"(ansi reset)(ansi blue)($in)(ansi reset)"
}

export def "color magenta" []: string -> string {
    $"(ansi reset)(ansi magenta)($in)(ansi reset)"
}

