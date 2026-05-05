
use procedure.nu *

def "nu-complete command-list-type" [] {
    help commands | get command_type | uniq
}
export def command-list [
    type?: string@"nu-complete command-list-type"
] {
    let commands = if $type == null {
        help commands
    } else {
        help commands | where command_type == $type
    }
    $commands | select name description | explore
}
