use path.nu 'path parent'

def "nu-complete plugin-names" [] {
    let bundled = ls ($nu.current-exe | path parent) | get name
    let installed = ls ~/.cargo/bin | get name
    $bundled ++ $installed | where {|e| $e | path basename | str starts-with "nu_plugin"}
}

alias plugin-add = plugin add

export def `plugin add` [
    plugin: string@"nu-complete plugin-names"
] {
    plugin-add $plugin
}
