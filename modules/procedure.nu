# ---------------------------------------------------------------------------- #
#                                 procedure.nu                                 #
# ---------------------------------------------------------------------------- #

use std null-device
use ansi.nu ['cursor off' 'cursor on' 'erase right' 'erase left']
use color.nu 'color apply'
use core.nu 'suppress all'

export def `procedure start` [] {
    cursor off
}

export def `procedure new-task` [
    name
    target?
    --width(-w): int = 20
    --continue(-c)
]: closure -> nothing {
    let task = $in
    print ""
    let $msg = match $target {
        null => ($name + "...")
        _ => ($name + " " + ($target | into string) + "...")
    }
    print $msg
    try {
        do $task $target o+e> null-device
        print ("  │\n  ╰─ Success" | color apply green)
    } catch {
        print ("  │\n  ╰─ Failed" | color apply red)
    }
}

export def `procedure new-subtask` [
    name: string
    target?
    --width(-w): int = 20
    --continue(-c)
]: closure -> nothing {
    let task = $in
    let $msg = match $target {
        null => ($name + "...")
        _ => ($name + " " + ($target | into string) + "...")
    }
    print -n ("  ├─── " + $msg + "\r")
    try {
        do $task $target o+e> null-device
        print (("  ├─── " | color apply green) + $msg)
    } catch {|err|
        if $continue {
            print (("  ├─── " | color apply yellow) + $msg)
        } else {
            print (("  ├─── " | color apply red) + $msg)
            error make -u { msg: $err }
        }
    }
}

# export def `procedure update-status` [task: string, update: string] {
#     print ($task + "  " + $update)
# }

export def `procedure end` [] {
    print ("________\nFinished" | color apply green)
    cursor on
}


#    Updating first...
#      │
#      ╰─ Success

#    Updating thing...
#      ├── Doing another.... Success
#      │
#      ╰─ Success

#    Updating second...
#      ├── Doing something.. Failed
#      ├── Doing another.... Success
#      │
#      ╰─ Success

#    Updating second...
#      ├── Doing something.. Success
#      ├── Doing something.. Failed
#      │
#      ╰─ Success