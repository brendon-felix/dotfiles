
def "nu-complete paint" [] {
    let list = ansi --list
    $list.name | append $list.short_name
}

export def main [
    style: string@"nu-complete paint" # the color or escape to apply (see `ansi --list`)
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
]: [
    any -> string
    list<any> -> list<string>
] {
    each {|e|
        mut result = (ansi $style)
        match $strip {
            true => ($result += ($e | into string | ansi strip)),
            false => ($result += ($e | into string))
        }
        match $no_reset {
            true => (),
            false => ($result += (ansi reset))
        }
        $result
    }
}
