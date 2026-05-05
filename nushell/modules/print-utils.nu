
# ---------------------------------------------------------------------------- #
#                                print-utils.nu                                #
# ---------------------------------------------------------------------------- #

use std null-device

export def `print each` [--no-newline(-n)] {
    each {|e|
        if $no_newline {
            print -n $e
        } else {
            print $e
        }
    } | ignore
}

export def blocks [n: int] {
    "" | fill -c '█' -w $n
}

export def spaces [n: int] {
    "" | fill -c ' ' -w $n
}

def "nu-complete reversable-colors" [] {
    ansi --list | get name | where $it !~ attr | where $it =~ reverse | str replace '_reverse' ''
}

export def pill [
    --width(-w): int
    color: string@"nu-complete reversable-colors" = green
]: [
    string -> string
    list<string> -> list<string>
] {
    each {|e|
        let text = $e
        let reverse = $color + _reverse
        let start = $"(ansi $color)(ansi reset)"
        let end = $"(ansi $color)(ansi reset)"
        let text = if $width != null {
            $text | fill -w ([($width - 2) 2] | math max) -a center
        } else {
            $text
        }
        let text = $"(ansi $reverse)($text)(ansi reset)"
        $"($start)(ansi $reverse)($text)(ansi reset)($end)"
    }
}

export def bar [
    value: float
    --length(-l): int = 12
    --fg-color(-f): any = '#DCDFE4'
    --bg-color(-b): any = '#505050'
    # --attr(-a): string
] {
    let bar = ^bar -l $length $value
    let ansi_color = {fg: $fg_color, bg: $bg_color}
    $"(ansi -e $ansi_color)($bar)(ansi reset)"
}

export def separator [
    length?: int
    --alignment(-a): string = 'c'
] {
    let input = match $in {
        null => ""
        _ => {match $alignment {
            'l' => $"($in) "
            'c' | 'm' | 'cr' | 'mr' => $" ($in) "
            'r' => $" ($in)"
        }}
    }
    let length = match $length {
        null => (term size).columns
        _ => $length
    }
    $input | fill -a $alignment -c '─' -w $length
}

export def --env suppress [
    what: string = 'all'
    --environment(-e)
]: closure -> nothing {
    let closure = $in
    match $what {
        'a' | 'all' => (do --env=$environment $closure o+e> (null-device))
        'e' | 'err' | 'stderr' => (do --env=$environment $closure e> (null-device))
        'o' | 'out' | 'stdout' => (do --env=$environment $closure o> (null-device))
        _ => {
            error make {
                msg: "invalid argument"
                label: {
                    text: "valid arguments are: 'all', 'err', 'stderr', 'out', 'stdout'"
                    span: (metadata $what).span
                }
            }
        }
    }
}

export def `progress set` [val: int] {
    if $val < 0 or $val > 100 {
        error make {
            msg: "invalid value"
            label: {
                text: "value must be between 0 and 100"
                span: (metadata $val).span
            }
        }
    }
    print -n $"(ansi osc)9;4;1;($val)(char bel)"
}

export def `progress unsure` [] {
    print =n $"(ansi osc)9;4;3(char bel)"
}

export def `progress clear` [] {
    print -n $"(ansi osc)9;4;0(char bel)"
}
