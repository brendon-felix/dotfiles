
use std repeat
use modules/paint.nu main
use modules/ansi.nu *

# def run-process [process] {
#     mut level = 0
#     print "─╮" " │"
#     let length = [(($process | get name | str length | math max) + 10) 60] | math min
#     for task in $process {
#         # print -n " ├─ " ($task.name + ' ' | fill -w ($length - 5) -c '-') " "
#         print-task $task.name 0 $length

#         complete-task $task $level $length

#         # try {
#         #     do $task.task
#         #     print ('done' | paint green)
#         # } catch {|err|
#         #     print ($err.msg | lines | first | paint red)
#         # }
#     }
# }

# def print-task [
#     name: string
#     level: int
#     length: int
#     --color(-c): string = default
# ] {
#     let margin = match $level {
#         0 => " ",
#         $n => (' ' + ('┆     ' | repeat $n | str join))
#     }
#     let fill_length = $length - ($margin | str length -g)
#     # print -n $"($margin)├─ ($name + ' ' | fill -w ($fill_length - 2) -c '-')" ' '
#     print -n $"($margin + '├─' | paint $color)(if $name == '' { '' } else { ' ' })($name)"
# }

# def complete-task [
#     task: any
#     level: int
#     length: int
# ] {
#     match ($task.task | describe -d).type {
#         closure => {
#             try {
#                 do $task.task
#                 # print ('done' | paint green)
#                 print -n "\r"
#                 print-task $task.name $level $length -c green
#                 print ""
#             } catch {|err|
#                 # print ($err.msg | lines | first | paint red)
#                 print -n "\r"
#                 print-task $task.name $level $length -c red
#                 print ""
#             }
#         }
#         list | table => {
#             let sub_tasks = $task.task
#             print ""
#             # print-task "" $level $length
#             # print "────╮"
#             let level = $level + 1
#             for sub_task in $sub_tasks {
#                 print-task $sub_task.name $level $length
#                 complete-task $sub_task $level $length
#             }
#             let level = $level - 1
#             print-task "" $level $length
#             print "────╯"
#         }
#     }
# }

def run-process [tasks] {
    clear
    cursor off
    # mut progress = $tasks | upsert status { "incomplete" | paint grey69 }
    $env.PROGRESS = $tasks | upsert status { "incomplete" | paint grey69 } | reject task continue
    mut failed = false
    for task in ($tasks | enumerate) {
        let task_progress = $env.PROGRESS | get $task.index
        $env.PROGRESS = $env.PROGRESS | update $task.index {
            $task_progress | update status ("working" | paint cyan)
        }
        let num_lines = (cursor position).row
        let term_width = (term size).columns
        for line in ..$num_lines {
            cursor up
            erase
        }
        # print $env.PROGRESS
        print ($env.PROGRESS | table -i false --theme compact)
        let status = match (complete-task $task.item $task.index) {
            "done" => ("done" | paint green)
            "error" => {
                match $task.item.continue {
                    true => ("error" | paint yellow)
                    false => { $failed = true; "error" | paint red }
                }
            }
        }
        $env.PROGRESS = $env.PROGRESS | update $task.index {
            $task_progress | update status $status
        }
        let num_lines = (cursor position).row
        let term_width = (term size).columns
        for line in ..$num_lines {
            cursor up
            erase
        }
        print ($env.PROGRESS | table -i false --theme compact)
        if $failed { break }
    }
    cursor on
}

def complete-task [
    task: any
    index: int
] {
    match ($task.task | describe -d).type {
        closure => {
            try {
                do $task.task
                "done"
            } catch {|err|
                "error"
            }
        }
        list | table => {
            # run-tasks $task.task
            let task_progress = $env.PROGRESS | get $index
            let num_subtasks = $task.task | length
            for subtask in ($task.task | enumerate) {
                let result = complete-task $subtask.item $index
                $env.PROGRESS = $env.PROGRESS | update $index {
                    $task_progress | update status ($"($subtask.index + 1)/($num_subtasks)" | paint grey69)
                }
                let num_lines = (cursor position).row
                let term_width = (term size).columns
                for line in ..$num_lines {
                    cursor up
                    erase
                }
                # print $env.PROGRESS
                print ($env.PROGRESS | table -i false --theme compact)
                if $result == "error" {
                    return "error"
                }
            }
            "done"
        }
    }
}

def main [] {
    let tasks = [
        [name                   task     continue];
        ["Doing a thing"        { sleep 250ms } true]
        ["And now another"      { sleep 100ms } true]
        # ["Almost done"          { sleep 2sec }]
        ["A multistep task" [
            [name task continue];
            ["Step one" { sleep 50ms } true ]
            ["Step two" { sleep 250ms } true]
            ["Step three" { sleep 250ms } true]
        ] true]
        ["This one throws an error" { sleep 250ms; error make -u {msg: "something went wrong"} } true]
        ["And now another"      { sleep 100ms } true]
        ["This one takes a while"      { sleep 3sec } true]
        ["Another multistep task" [
            [name task continue];
            ["Doing a thing" { sleep 500ms } true]
            ["Doing another" [
                [name task continue];
                ["Subtask A" { sleep 250ms } true]
                ["Subtask B" { sleep 50ms } true]
            ] true]
            ["Doing the last subtask" [
                [name task continue];
                ["Final step 1" { sleep 100ms } true]
                ["Final step 2" { sleep 250ms } true]
            ] true]
        ] true]
        ["And now another"      { sleep 50ms } true]
        ["This is the last one" { sleep 250ms } true]
    ]
    # print $tasks
    # print ($tasks | describe -d)
    run-process $tasks
}
