
# ---------------------------------------------------------------------------- #
#                                 procedure.nu                                 #
# ---------------------------------------------------------------------------- #

use std repeat

use print-utils.nu [separator suppress]
use paint.nu main
use ansi.nu ['cursor off' 'cursor on']

export def `procedure run` [
    name: string
    closure: closure
    --debug(-d)
] {
    cursor off
    print ($"Running ($name)" | separator)
    $env.PROCEDURE_LEVEL = 0
    $env.PROCEDURE_DEBUG = $debug
    # $env.PROCEDURE_LEAF = true
    try {
        do $closure
        print ($"\n($name) successful" | paint green)
        print (separator)
    } catch {
        print ($"\n($name) failed" | paint red)
        print (separator)
    }
    cursor on
}

def left_margin [level] {
    match $level {
        0 => "",
        $n => ('  ' + ('┆     ' | repeat ($n - 1) | str join))
    }
}

def print-task [name] {
    match ($env.PROCEDURE_LEVEL - 1) {
        0 => {
            print $name
        }
        $n => {
            let left_margin = left_margin $n
            print $"($left_margin)├─→ ($name)"
        }
    }
}

def print-result [result] {
    let result = match $result {
        success => {text: "Success", icon: "✓", color: green}
        warning => {text: "Warning", icon: "!", color: yellow}
        error => {text: "Failed", icon: "×", color: red}
    }
    match ($env.PROCEDURE_LEVEL - 1) {
        $n if ($env.PROCEDURE_LEAF and ($n >= 1)) => {()}
        0 => {
            print ($"  │" | paint $result.color)
            print ($"  ╰─→ ($result.text)\n" | paint $result.color)
        }
        $n => {
            let left_margin = left_margin $n
            print ($left_margin + ($"╭─────╯ ($result.icon)" | paint $result.color))
            print ($left_margin + ($"│" | paint $result.color))
        }
    }
}

export def --env `procedure new-task` [
    name: string
    task: closure
    --continue(-c)
    --on-error(-e): string
] {
    let left_margin = left_margin $env.PROCEDURE_LEVEL
    $env.PROCEDURE_LEVEL += 1
    try {
        print-task $name
        $env.PROCEDURE_LEAF = true
        $task | suppress all -e
        print-result success
        $env.PROCEDURE_LEVEL -= 1
        $env.PROCEDURE_LEAF = false
    } catch {|err|
        if $env.PROCEDURE_DEBUG { print $err.rendered }
        let color = if $continue { 'yellow' } else { 'red' }
        match $on_error {
            null => (procedure print $err.msg -c $color)
            $msg => (procedure print $msg -c $color)
        }
        match $continue {
            true => {
                print-result warning
                $env.PROCEDURE_LEVEL -= 1
                $env.PROCEDURE_LEAF = false
            }
            false => {
                print-result error
                # $env.PROCEDURE_LEVEL -= 1
                $env.PROCEDURE_LEVEL -= 1
                $env.PROCEDURE_LEAF = false
                error make -u { msg: "task failed" }
            }
        }
    }
    ()
}

export def `procedure print` [
    message: string
    --color(-c): string = 'default'
] {
    let message = match ($env.PROCEDURE_LEVEL - 1) {
        $n if $n < 0 => (error make -u { msg: "invalid procedure level" }),
        $n if $n == 0 => ("  │    ╰─ " + $message | paint $color),
        $n => ($"(left_margin $n)" + ("│    ╰─ " + $message | paint $color))
    }
    print $message
}

export def `procedure get-input` [
    prompt: string
    --color(-c): string = 'default'
    --numchar(-n): int,
    --default(-d): string,
] {
    let prompt = match ($env.PROCEDURE_LEVEL - 1) {
        $n if $n < 0 => (error make -u { msg: "invalid procedure level" }),
        $n if $n == 0 => ("  │    ╰─ " + $prompt | paint $color),
        $n => ($"(left_margin $n)" + ("│    ╰─ " + $prompt | paint $color))
    }
    input $prompt --numchar=$numchar --default=$default
}
