# ---------------------------------------------------------------------------- #
#                                 procedure.nu                                 #
# ---------------------------------------------------------------------------- #

use std null-device
use print-utils.nu separator
use ansi.nu *
use color.nu 'color apply'
use core.nu 'suppress all'

# export def `procedure run` [
#     name: string
#     closure: closure
# ] {
#     cursor off
#     print ($"Running ($name)" | separator)
#     try {
#         do $closure
#         print ($"($name) successful" | color apply green)
#         print (separator)
#     } catch {
#         print (separator)
#         print ($"($name) failed" | color apply red)
#     }
    
#     cursor off
# }

# export def `procedure new-task` [
#     name: string
#     task: closure
# ] {

# }

export def `procedure new-task` [
    name: string
    task: closure
    --get-result(-r)
    --width(-w): int = 20
    --continue(-c)
] {
    print ""
    let $msg = $name + '...'
    print $msg
    try {
        match $get_result {
            false => {
                (do $task o+e> (null-device))
                # (do $task)
                print ("  │\n  ╰─ Success" | color apply green)
            }
            true => {
                let result = (do $task) | into string
                print $"  │\n  ╰─ ($result)"
            }
        }
    } catch {|err|
        # print $err
        print ("  │\n  ╰─ Failed" | color apply red)
    }
}

export def `procedure print` [
    message: string
    --width(-w): int = 20
] {
    print ("  ├─── " + $message)
}

export def `procedure info` [
    message: string
    --width(-w): int = 20
] {
    print ("  ├─── " + $message | color apply blue)
}

export def `procedure success` [
    message: string
    --width(-w): int = 20
] {
    print ("  ├─── " + $message | color apply green)
}

export def `procedure warning` [
    message: string
    --width(-w): int = 20
] {
    print ("  ├─── " + $message | color apply yellow)
}

export def `procedure error` [
    message: string
    --width(-w): int = 20
] {
    print ("  ├─── " + $message | color apply red)
}

export def `procedure new-subtask` [
    name: string
    task: closure
    --get-result(-r)
    --width(-w): int = 20
    --continue(-c)
] {
    let $msg = $name + '...'
    print -n ("  ├─── " + $msg + "\r")
    try {
        match $get_result {
            false => {
                (do $task o+e> (null-device))
                # (do $task)
                print (("  ├─── " | color apply green) + $msg)
            }
            true => {
                let result = (do $task) | into string
                print $"  ├─── ($msg) ($result)"
            }
        }
    } catch {|err|
        # print $err
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