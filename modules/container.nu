
# ---------------------------------------------------------------------------- #
#                                 container.nu                                 #
# ---------------------------------------------------------------------------- #

# Converts piped input into a container (list of strings)
export def contain [
    --pad(-p): string = normal      # padding style: normal (n), comfy (c), tight (t)
    --pad-x(-x): int = 0,           # horizontal padding
    --pad-left(-l): int = 0,        # left padding
    --pad-right(-r): int = 0,       # right padding
    --pad-y(-y): int = 0,           # vertical padding
    --pad-top(-t): int = 0,         # top padding
    --pad-bottom(-b): int = 0,      # bottom padding
    --alignment(-a): string = l     # text alignment for fill (see `fill -h`)
]: any -> list<string> {
    let input = [$in] | each {|e| $e | into string | lines} | flatten
    let max_length = $input | ansi strip | str length -g | math max
    let padding = match $pad {
        n | normal => {
            top: ("" | repeat ([$pad_y $pad_top] | math max))
            bottom: ("" | repeat ([$pad_y $pad_bottom] | math max))
            left: ("" | fill -w ([$pad_x $pad_left 1] | math max))
            right: ("" | fill -w ([$pad_x $pad_right 1] | math max))
        }
        c | comfy => {
            top: ("" | repeat ([$pad_y $pad_top 1] | math max))
            bottom: ("" | repeat ([$pad_y $pad_bottom 1] | math max))
            left: ("" | fill -w ([$pad_x $pad_left 2] | math max))
            right: ("" | fill -w ([$pad_x $pad_right 2] | math max))
        }
        t | tight => {
            top: ("" | repeat ([$pad_y $pad_top] | math max))
            bottom: ("" | repeat ([$pad_y $pad_bottom] | math max))
            left: ("" | fill -w ([$pad_x $pad_left] | math max))
            right: ("" | fill -w ([$pad_x $pad_right] | math max))
        }
    }
    let filled = $input | prepend $padding.top | append $padding.bottom | each {|line|
        $line | fill -a $alignment -w $max_length
    }
    let container_width = $max_length + $pad_left + $pad_right
    $filled | each {|line| 
        $padding.left + $line + $padding.right
    }
}

# Places a box (border) around a container
export def box []: list<string> -> list<string> {
    let container = $in
    let max_length = $container | ansi strip | str length -g | math max
    let horizontal_border = ("" | fill -c '─' -w $max_length | str join)
    let top_border = $"╭($horizontal_border)╮"
    let middle = $container | each { |line| $"│($line)│" }
    let bottom_border = $"╰($horizontal_border)╯"
    $middle | prepend $top_border | append $bottom_border
}

# Places a double box (border) around a container
export def double-box []: list<string> -> list<string> {
    let container = $in
    let max_length = $container | ansi strip | str length -g | math max
    let horizontal_border = ("" | fill -c '═' -w $max_length | str join)
    let top_border = $"╔($horizontal_border)╗"
    let middle = $container | each { |line| $"║($line)║" }
    let bottom_border = $"╚($horizontal_border)╝"
    $middle | prepend $top_border | append $bottom_border
}

# places a container to the right of another container
export def row [
    right: list<string>             # container to place to the right
    --alignment(-a): string = t     # alignment of the right container: top (t), bottom (b), center (c), center_bottom (cb)
    --spacing(-s): int = 1          # number of spaces between the two containers
]: list<string> -> list<string> {
    let left = [$in] | each {|e| $e | into string | lines} | flatten
    let right = [$right] | each {|e| $e | into string | lines} | flatten
    if ($left | length) == 0 {
        return $right
    } else if ($right | length) == 0 {
        return $left
    }
    let tpad = match {left: ($left | length), right: ($right | length)} {
        $h if $h.left == $h.right => {left: 0, right: 0}
        $h if $h.left > $h.right => {left: 0, right: ($h.left - $h.right)}
        $h if $h.left < $h.right => {left: ($h.right - $h.left), right: 0 }
    }
    let padding = match $alignment {
        t | top => { left: {top: 0, bottom: $tpad.left}, right: {top: 0, bottom: $tpad.right} }
        b | bottom => { left: {top: $tpad.left, bottom: 0}, right: {top: $tpad.right, bottom: 0} }
        c | center => {
            left: { top: ($tpad.left / 2 | math floor), bottom: ($tpad.left / 2 | math ceil) }
            right: { top: ($tpad.right / 2 | math floor), bottom: ($tpad.right / 2 | math ceil) }
        }
        cb | center_bottom => {
            left: { top: ($tpad.left / 2 | math ceil), bottom: ($tpad.left / 2 | math floor) }
            right: { top: ($tpad.right / 2 | math ceil), bottom: ($tpad.right / 2 | math floor) }
        }
    }
    let left_pad_line = "" | fill -w ($left | strip length | math max)
    let right_pad_line = "" | fill -w ($right | strip length | math max)
    let padding = {
        left: {
            top: ($left_pad_line | repeat $padding.left.top), 
            bottom: ($left_pad_line | repeat $padding.left.bottom)
        }
        right: {
            top: ($right_pad_line | repeat $padding.right.top), 
            bottom: ($right_pad_line | repeat $padding.right.bottom)
        }
    }
    let left = $left | prepend $padding.left.top | append $padding.left.bottom
    let right = $right | prepend $padding.right.top | append $padding.right.bottom
    ($left | zip $right) | each { |pair|
        $"($pair.0)("" | fill -w $spacing)($pair.1)"
    }
}

# Places a container in a specified location in the terminal with size and color options
export def div [
    # --type(-t): string = f          # type of the div: horizontal (h), vertical (v), fill (f)
    --position(-p): any = center    # position of the container (t, ul, l, bl, b, br, r, ur, c or record<x: int, y: int>)
    --background(-b): any = default # background color (ansi name or escape)
    --shorten-by(-s): int = 1       # shorten the div by this many rows
    --fill(-f)                      # apply background color to the whole container
]: list<string> -> list<string> {
    let container = $in
    let container_width = $container | ansi strip | str length -g | math max
    let container_height = $container | length
    let term_size = (term size)
    let position = match $position {
        't' | "top" =>          { x: 'c', y: 't' }
        'ul' | "upperleft" =>   { x: 'l', y: 't' }
        'l' | "left" =>         { x: 'l', y: 'c' }
        'bl' | "bottomleft" =>  { x: 'l', y: 'b' }
        'b' | "bottom" =>       { x: 'c', y: 'b' }
        'br' | "bottomright" => { x: 'r', y: 'b' }
        'r' | "right" =>        { x: 'r', y: 'c' }
        'ur' | "upperight" =>   { x: 'r', y: 't' }
        'c' | "center" =>       { x: 'c', y: 'c' }
        $pos if ($pos | describe) == "record<x: int, y: int>" => $pos
        _ => {
            error make {
                msg: "Invalid position",
                label: {
                    text: $"The position '($position)' is not recognized.",
                    span: (metadata $position).span
                }
            }
        }
    }
    # let height = (term size).rows
    let total_y_padding = $term_size.rows - $container_height - $shorten_by
    let y_padding_height = match $position.y {
        't' | "top" => {top: 0, bottom: $total_y_padding}
        'c' | "center" => {
            top: ($total_y_padding / 2 | math floor)
            bottom: ($total_y_padding / 2 | math ceil)
        }
        'b' | "bottom" => {top: $total_y_padding, bottom: 0}
        $y if ($y | describe) == "int" => {
            top: $y
            bottom: ($total_y_padding - $y)
        }
    }
    let total_x_padding = $term_size.columns - $container_width
    let x_padding_width = match $position.x {
        'l' | "left" => {left: 0, right: $total_x_padding}
        'c' | "center" => {
            left: ($total_x_padding / 2 | math floor)
            right: ($total_x_padding / 2 | math ceil)
        }
        'r' | "right" => {left: $total_x_padding, right: 0}
        $x if ($x | describe) == "int" => {
            left: $x
            right: ($total_x_padding - $x)
        }
    }
    let padding = {
        top: ("" | fill -w $term_size.columns | repeat $y_padding_height.top | color apply {bg: $background})
        bottom: ("" | fill -w $term_size.columns | repeat $y_padding_height.bottom | color apply {bg: $background})
        left: ("" | fill -w $x_padding_width.left | color apply {bg: $background})
        right: ("" | fill -w $x_padding_width.right | color apply {bg: $background})
    }
    $container | each { |line| 
        mut line = $padding.left + $line + $padding.right
        if $fill {
            $line = $line | color apply {bg: $background}
        }
        $line
    } | prepend $padding.top | append $padding.bottom
}

export def "container print" []: list<string> -> nothing {
    print ($in | str join "\n")
}

