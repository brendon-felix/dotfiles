
export def `re-export all` [
    directory: path = '.'
    --dry-run
] {
    let pattern = $directory | path join '*.nu' | into glob
    let module_names = ls $pattern | where {|m| ($m.name | path basename) != 'mod.nu'} | get name
    let re_exports = $module_names | each {|m|
        $"export use ($m | path basename) *"
    }
    if $dry_run {
        print ($re_exports | str join "\n" | highlight nu)
    } else {
        let mod_file = $directory | path join 'mod.nu'
        $re_exports | save -f $mod_file
    }
}

def "nu-complete command-list-type" [] {
    ['built-in', 'external', 'custom', 'alias', 'plugin']
}

export def command-list [
    type?: string@"nu-complete command-list-type"
] {
    let commands = if $type == null {
        help commands
    } else {
        help commands | where command_type == $type
    }
    $commands | select name description
}
