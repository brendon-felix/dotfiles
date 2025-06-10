# ---------------------------------------------------------------------------- #
#                                   color.nu                                   #
# ---------------------------------------------------------------------------- #


export def "color green" []: string -> string {
    $"(ansi green)($in | ansi strip)(ansi reset)"
}

export def "color red" []: string -> string {
    $"(ansi red)($in | ansi strip)(ansi reset)"
}

export def "color yellow" []: string -> string {
    $"(ansi yellow)($in | ansi strip)(ansi reset)"
}

export def "color cyan" []: string -> string {
    $"(ansi cyan)($in | ansi strip)(ansi reset)"
}

export def "color blue" []: string -> string {
    $"(ansi blue)($in | ansi strip)(ansi reset)"
}

export def "color magenta" []: string -> string {
    $"(ansi magenta)($in | ansi strip)(ansi reset)"
}

export def "color purple" []: string -> string {
    $"(ansi light_purple)($in | ansi strip)(ansi reset)"
}

export def "color length" []: string -> int {
    $in | ansi strip | str length -g
}