
# ---------------------------------------------------------------------------- #
#                                 procedure.nu                                 #
# ---------------------------------------------------------------------------- #

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
        print ($"\n($name) successful" | ansi apply green)
        print (separator)
    } catch {
        print ($"\n($name) failed" | ansi apply red)
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
            print ($"  │" | ansi apply $result.color)
            print ($"  ╰─→ ($result.text)\n" | ansi apply $result.color)
        }
        $n => {
            let left_margin = left_margin $n
            print ($left_margin + ($"╭─────╯ ($result.icon)" | ansi apply $result.color))
            print ($left_margin + ($"│" | ansi apply $result.color))
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
        if $on_error != null {
            procedure print $on_error -c yellow
            # if $continue {
            #     procedure print $on_error -c yellow
            # } else {
            #     procedure print $on_error -c red
            # }
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
                error make -u { msg: "Failed" }
            }
        }
    }
    ()
}

export def `procedure print` [
    message: string
    --color(-c): string
] {
    let message = match ($env.PROCEDURE_LEVEL - 1) {
        0 => $message,
        $n => ($"(left_margin $n)" + ("│    ╰─ " + $message | ansi apply $color))
    }
    print $message
}

