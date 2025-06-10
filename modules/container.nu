use std repeat
use std ellie

use print-utils.nu debug

# export def box [
#     --pad-x(-x): int = 1,
#     --pad-left(-l): int = 1,
#     --pad-right(-r): int = 1,
#     --pad-y(-y): int = 0,
#     --pad-top(-t): int = 0,
#     --pad-bottom(-m): int = 0,
#     --alignment(-a): string = 'l',
#     --no-border(-b)
# ] {
#     mut input = [$in] | each {|e| $e | into string | lines} | flatten
#     let pad_top = ([$pad_y $pad_top] | math max)
#     let pad_bottom = ([$pad_y $pad_bottom] | math max)
#     $input = $input | prepend ("" | repeat $pad_top) | append ("" | repeat $pad_bottom)
#     # debug $input
#     let max_length = $input | ansi strip | str length -g | math max
#     let pad_left = match $pad_x { 0 => 0, _ => ([$pad_x $pad_left] | math max) }
#     let pad_right = match $pad_x { 0 => 0, _ => ([$pad_x $pad_right] | math max) }
#     let box_width = $max_length + $pad_left + $pad_right
#     mut middle = $input | each { |line| 
#         let filled = $line | fill -a $alignment -w $max_length
#         let left_padding = ' ' | repeat $pad_left | str join
#         let right_padding = ' ' | repeat $pad_right | str join
#         let padded_line = $left_padding + $filled + $right_padding
#         if $no_border {
#             $"($padded_line)"
#         } else {
#             $"│($padded_line)│"
#         }
#     }
#     if $no_border {
#         $middle
#     } else {
#         let horizontal_border = ("" | fill -c '─' -w $box_width | str join)
#         $middle | prepend $"╭($horizontal_border)╮" | append $"╰($horizontal_border)╯"
#     }
# }

export def contain [
    --pad-x(-x): int = 1,
    --pad-left(-l): int = 1,
    --pad-right(-r): int = 1,
    --pad-y(-y): int = 0,
    --pad-top(-t): int = 0,
    --pad-bottom(-b): int = 0,
    --alignment(-a): string = 'l'
]: any -> list<string> {
    let input = [$in] | each {|e| $e | into string | lines} | flatten
    let max_length = $input | ansi strip | str length -g | math max
    let top_padding = "" | repeat ([$pad_y $pad_top] | math max)
    let bottom_padding = "" | repeat ([$pad_y $pad_bottom] | math max)
    let lines = $input | prepend $top_padding | append $bottom_padding
    let pad_left = match $pad_x { 0 => 0, _ => ([$pad_x $pad_left] | math max) }
    let pad_right = match $pad_x { 0 => 0, _ => ([$pad_x $pad_right] | math max) }
    let container_width = $max_length + $pad_left + $pad_right
    $lines | each { |line| 
        let filled = $line | fill -a $alignment -w $max_length
        let left_padding = "" | fill -w $pad_left
        let right_padding = "" | fill -w $pad_right
        $left_padding + $filled + $right_padding
    }
}

export def box []: list<string> -> list<string> {
    let container = $in | contain -x 0 -y 0
    let max_length = $container | ansi strip | str length -g | math max
    let horizontal_border = ("" | fill -c '─' -w $max_length | str join)
    let top_border = $"╭($horizontal_border)╮"
    let middle = $container | each { |line| $"│($line)│" }
    let bottom_border = $"╰($horizontal_border)╯"
    $middle | prepend $top_border | append $bottom_border
}

export def row [right, --alignment(-a): string = 't', --spacing(-s): int = 1]: any -> list<string> {
    mut left = [$in] | each {|e| $e | into string | lines} | flatten
    mut right = [$right] | each {|e| $e | into string | lines} | flatten
    let left_height = $left | length
    let right_height = $right | length
    let diff = $left_height - $right_height
    let padding = "" | repeat ($diff | math abs)
    match $alignment {
        t | top => {
            if $diff > 0 {
                $right = $right | append $padding
            } else {
                $left = $left | append $padding
            }
        }
        b | bottom => {
            if $diff > 0 {
                $right = $right | prepend $padding
            } else {
                $left = $left | prepend $padding
            }
        }
        c | center => {
            if $diff > 0 {
                let left_padding = "" | repeat ($diff / 2 | math floor)
                let right_padding = "" | repeat ($diff - ($diff / 2 | math floor))
                $right = $right | prepend $left_padding | append $right_padding
            } else {
                let left_padding = "" | repeat ($diff / 2 | math floor)
                let right_padding = "" | repeat ($diff - ($diff / 2 | math floor))
                $left = $left | prepend $left_padding | append $right_padding
            }
        }
    }
    ($left | zip $right) | each { |pair|
        $"($pair.0)("" | fill -w $spacing)($pair.1)"
    }
}

export def "print container" []: list<string> -> nothing {
    print ($in | str join "\n")
}

def main [] {
    # let result = ellie | ansi strip | contain -b 1
    # $result | debug
    # $result | box | print container
    let left = "This\nis a TEST\nof the co\nnn\ntainer" | contain -y 1 -a r | box
    let right = "This is a test of the container\non the right side" | contain -y 1 -a l | box
    $left | row -a t $right | contain | box | print container
}

