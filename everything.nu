# ---------------------------------------------------------------------------- #
#                                 everything.nu                                #
# ---------------------------------------------------------------------------- #

use std [ellie repeat null-device]


# ---------------------------------------------------------------------------- #
#                                    ansi.nu                                   #
# ---------------------------------------------------------------------------- #

export def `strip length` []: [
    string -> int
    list<string> -> list<int>
] {
    $in | ansi strip | str length -g
}

export def `ansi alternate` [] {
    ansi -e "?1049h"
}

export def `ansi main` [] {
    ansi -e "?1049l"
}

# -------------------------------- formatting -------------------------------- #

export def bold [] {
    each { |e|
        $"(ansi attr_bold)($e)(ansi reset)"
    }
}

export def dimmed [] {
    each { |e|
        $"(ansi attr_dimmed)($e)(ansi reset)"
    }
}

export def italic [] {
    each { |e|
        $"(ansi attr_italic)($e)(ansi reset)"
    }
}

export def underline [] {
    each { |e|
        $"(ansi attr_underline)($e)(ansi reset)"
    }
}

export def blink [] {
    each { |e|
        $"(ansi attr_blink)($e)(ansi reset)"
    }
}

export def hidden [] {
    each { |e|
        $"(ansi attr_hidden)($e)(ansi reset)"
    }
}

export def strike [] {
    each { |e|
        $"(ansi attr_strike)($e)(ansi reset)"
    }
}

# ------------------------------ cursor commands ----------------------------- #

export def `erase right` [] {
    print -n $"(ansi erase_line_from_cursor_to_end)"
}

export def `erase left` [] {
    print -n $"(ansi erase_line_from_cursor_to_beginning)"
}

export def erase [] {
    print -n $"(ansi erase_line)"
}

export def `cursor off` [] {
    print -n $"(ansi cursor_off)"
}

export def `cursor on` [] {
    print -n $"(ansi cursor_on)"
}

export def `cursor home` [] {
    print -n $"(ansi cursor_home)"
}

export def `cursor blink` [] {
    print -n $"(ansi cursor_blink_on)"
}

export def `cursor left` [] {
    print -n $"(ansi cursor_left)"
}

export def `cursor right` [] {
    print -n $"(ansi cursor_right)"
}

export def `cursor up` [] {
    print -n $"(ansi cursor_up)"
}

export def `cursor down` [] {
    print -n $"(ansi cursor_down)"
}

export def `cursor position` [] {
    let pos = term query (ansi cursor_position) --prefix (ansi csi) --terminator 'R' | decode | parse "{row};{col}" | first
    {
        row: ($pos.row | into int),
        col: ($pos.col | into int),
    }
}

export def `cursor move-to` [
    pos: record<row: int, col: int>
] {
    print -n (ansi -e $"($pos.row);($pos.col)f")
}


# ---------------------------------------------------------------------------- #
#                                applications.nu                               #
# ---------------------------------------------------------------------------- #

export def `start app` [app_name] {
    let shortcut_filename = $"($app_name).lnk"
    let possible_paths = [
        ([$env.APPDATA, `Microsoft\Windows\Start Menu\Programs`, $shortcut_filename] | path join),
        ([$env.APPDATA, `Microsoft\Windows\Start Menu\Programs`, $app_name, $shortcut_filename] | path join),
        ([$env.ProgramData, `Microsoft\Windows\Start Menu\Programs`, $shortcut_filename] | path join),
        ([$env.ProgramData, `Microsoft\Windows\Start Menu\Programs`, $app_name, $shortcut_filename] | path join)
    ]
    mut result: any = null
    for path in $possible_paths {
        if ($path | path exists) {
            $result = $path
        }
    }
    if $result == null {
        error make {
            msg: $"Shortcut for ($app_name) not found in any of the expected paths.",
            label: {
                text: "Application not found"
                span: (metadata $app_name).span
            }
        }
    } else {
        start $result
    }
}

# export alias ticktick = start_app "TickTick"
# export alias todo = start_app "TickTick"
# export alias obsidian = start_app "Obsidian"
# export alias notes = start_app "Obsidian"
# export alias zen = start_app "Zen"
# export alias arc = start_app "Arc"
# export alias rw = start_app "Rw"
# export alias email = start_app "Spark Desktop"
# export alias excel = start_app "Excel"
# export alias chrome = start_app "Google Chrome"
# export alias onedrive = start_app "OneDrive"
# export alias word = start_app "Word"

export alias obsidian = start obsidian://open?vault=ArrowHead
export alias notes = start obsidian://open?vault=ArrowHead


# ---------------------------------------------------------------------------- #
#                                   banner.nu                                  #
# ---------------------------------------------------------------------------- #

# use version.nu 'version check'


def startup []: nothing -> string {
    let startup_time = ($nu.startup-time | round duration ms)
    match $startup_time {
        $t if $t == 0sec => null
        $t if $t < 100ms => ($t | into string | color apply green)
        $t if $t < 500ms => ($t | into string | color apply yellow)
        $t => ($t | into string | color apply red)
    }
}

def uptime []: nothing -> string {
    match (sys host).uptime {
        $t if $t < 1day => ($t | round duration min | into string | color apply green)
        $t if $t < 1wk => ($t | round duration hr | into string | color apply yellow)
        $t => ($t | round duration day | into string | color apply red)
    }
}

def header_text []: nothing -> list<string> {
    let curr_version = match (version check) {
        $c if $c.current => ($"v($env.NU_VERSION)" | color apply green)
        $c => ($"v($env.NU_VERSION)" | color apply yellow)
    }
    # let curr_version = $env.NU_VERSION | color apply green
    let shell = ("Nushell " | color apply green) + $curr_version
    let username = $env.USERNAME | color apply light_purple
    let hostname = sys host | get hostname | color apply light_purple
    let user = $"($username)@($hostname)"

    let width = [($shell | strip length), ($user | strip length)] | math max
    let separator = "" | fill -c '─' -w $width
    [$shell $separator $user] | contain -p tight
}

def info_text [
    type?: string = "keyval" # the type of info to display: keyval, english, record
    --bar(-b)
]: nothing -> list<string> {
    let startup = startup
    let uptime = uptime
    let memory = status memory --no-bar=(not $bar)
    let info = match $type {
        keyval => {
            [
                $"(ansi light_blue)startup:(ansi reset) ($startup)"
                $"(ansi light_blue)uptime:(ansi reset) ($uptime)"
                $"(ansi light_blue)memory:(ansi reset) ($memory.RAM)"
            ]
        }
        english => {
            [
                $"It took ($startup) to start this shell."
                $"This system has been up for ($uptime)."
                $"($memory.RAM) of memory is in use."
            ]
        }
        record => {
            {
                startup: $startup
                uptime: $uptime
                memory: $memory.RAM
            }
        }
        _ => {
            error make {
                msg: "invalid info type"
                label: {
                    text: "type not recognized"
                    span: (metadata $type).span
                }
                help: "Use `banner --help` to see available types."
            }
        }
    }
    $info
}

# container-based ellie
export def my-ellie []: nothing -> list<string> {
    ellie | ansi strip | contain -x 2 --pad-bottom 1
}

def header []: nothing -> list<string> {
    my-ellie | color apply green | row -s 0 -a c (header_text | contain -p t --pad-top 1 --pad-right 2) | contain -p tight
}

def tight_header []: nothing -> list<string> {
    my-ellie | row -s 2 -a c (header_text) | contain -p tight
}

export alias `builtin banner` = banner

# Prints a custom banner
export def `print banner` [
    type? = memory # the type of banner to print: ellie, header, info, row, stack
] {
    banner $type | contain -p t | container print
}

export def `print info` [
    type?: string = record # the type of info to print: keyval, english, record
    --bar(-b)
] {
    if $type == "record" {
        print (info_text --bar=$bar record)
    } else {
        info_text $type --bar=$bar | contain -p c | box | container print
    }
}

export def info [--bar] {
    info_text --bar=$bar record
}

# Creates a custom container-based banner
def banner [
    type?: string = memory # the type of banner to create: # ellie, user, header, info, info_english, info_record, row, stack, row_english, stack_english, memory, mem_disks, test
]: nothing -> list<string> {
    match $type {
        ellie => (my-ellie | color apply green | box)
        user => (header_text | contain -p c | box)
        header => (header | box)
        info => (info_text | contain -p "comfy" | box)
        info_english => (info_text english | contain -p "comfy" | box)
        info_record => (info_text record)
        row => (header | box | row -a b (info_text | contain | box))
        stack => (header | box | append (info_text | contain | box) | contain -p tight)
        row_english => (header | box | row -a b (info_text english | contain | box))
        stack_english => (header | box | append (info_text english | contain | box) | contain -p tight)
        memory => (header | append $"RAM: (status memory | get RAM)"| contain -a c | box)
        mem_disks => (header | append $"("RAM" | color apply blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | color apply blue): ($status)"}) | contain -a l | box)
        test => (header | box | row -s 2 -a c (info_text english))
        _ => {
            error make {
                msg: "invalid banner type"
                label: {
                    text: "type not recognized"
                    span: (metadata $type).span
                }
                help: "Use `banner --help` to see available types."
            }
        }
    }
    # header | append $"("RAM" | color apply blue): (status memory | get RAM)" | append (status disks | items {|mount status| $"($mount | color apply blue): ($status)"}) | contain -a c | box
}


# ---------------------------------------------------------------------------- #
#                                 color-show.nu                                #
# ---------------------------------------------------------------------------- #


export def `color show` [] {
    $in | each {|e|
        let color_hex = match ($e | describe) {
            "record<r: int, g: int, b: int>" => $e
            "record<h: int, s: float, v: float>" => ($e | rgb from-hsv)
            _ => ($e | into rgb)
        } | rgb get-hex
        let ansi_colors = [
            {fg: $color_hex},
            {bg: $color_hex},
            {fg: $color_hex, attr: 'r'},
            {bg: $color_hex, attr: 'r'},
        ]
        mut container = []
        for ansi_color in $ansi_colors {
            # print $"(ansi -e $ansi_color)(ansi reset)"
            $container = $container | row (my-ellie | color apply $ansi_color)
        }
        $container | container print
    }
}

export def `print window` [] {
    let container = [
        "╭────┬────╮"
        "│    │    │"
        "├────┼────┤"
        "│    │    │"
        "╰────┴────╯"
    ]
    $container | container print
}


# ---------------------------------------------------------------------------- #
#                                   color.nu                                   #
# ---------------------------------------------------------------------------- #

# use container.nu [contain 'container print']

# apply ANSI color or attributes to a piped string
export def `color apply` [
    color           # the color or escape to apply (see `ansi --list`)
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
]: [
    string -> string
    list<string> -> list<string>
] {
    each { |e|
        let e = match $strip {
            true => ($e | ansi strip),
            false => $e
        }
        match $color {
            $c if ($c | describe) == "string" => $"(ansi $c)($e)(ansi reset)"
            $c if ($c | describe) == "record<r: int, g: int, b: int>" => $"(ansi --escape {fg: ($c | into rgb | rgb get-hex)})($e)(ansi reset)"
            $c if ($c | describe) == "record<h: int, s: float, v: float>" => $"(ansi --escape {fg: ($c | into rgb | rgb get-hex)})($e)(ansi reset)"
            $c if ($c | describe | str starts-with "record") => $"(ansi --escape $c)($e)(ansi reset)"
            _ => {
                error make -u { msg: "Invalid color format" }
            }
        }
    }
}

export def `color interpolate` [
    start,
    end,
    t?: float = 0.5,
    --hsv
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
] {
    let start = if $hsv { $start | into rgb | rgb get-hsv } else { $start | into rgb }
    let end = if $hsv { $end | into rgb | rgb get-hsv } else { $end | into rgb }
    mut color = $start | interpolate $end $t
    if $hsv { $color = $color | rgb from-hsv }
    let hex = $color | rgb get-hex
    $in | each {|e| $e | color apply {fg: $hex} --strip=$strip --no-reset=$no_reset}
}

export def `color gradient` [
    start,          # start color (can be RGB or HSV)
    end,            # end color (can be RGB or HSV)
    --hsv           # use HSV color space for interpolation
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
]: string -> string {
    let start = if $hsv { $start | into rgb | rgb get-hsv } else { $start | into rgb }
    let end = if $hsv { $end | into rgb | rgb get-hsv } else { $end | into rgb }
    $in | each {|e|
        let length = $e | str length
        $e | split chars | enumerate | each {|i|
            let t = $i.index / $length
            mut interpolated = $start | interpolate $end $t
            if $hsv { $interpolated = $interpolated | rgb from-hsv }
            let hex = $interpolated | rgb get-hex
            $i.item | color apply {fg: $hex} --strip=$strip --no-reset=$no_reset
            # $"(ansi -e {fg: $hex})($e.item)(ansi reset)"
        }
    } | str join
}

export def `color cycle` [i] {
    let colors = [
        "red",
        "green",
        "blue", 
        "yellow",
        "magenta",
        "cyan",
        "white"
    ]
    $in | each {|e|
        let index = ($i | into int) mod ($colors | length)
        $e | color apply ($colors | get $index)
    }
}

export def `color random` [
    --hsv
    --strip(-s)     # strip ANSI codes from input before applying color
    --no-reset(-r)  # do not reset ansi after applying
] {
    each {|e|
        let color = if $hsv {
            {h: (random float 0..<360), s: (random float 0..<1), v: (random float 0..<1)}
        } else {
            {r: (random int 0..255), g: (random int 0..255), b: (random int 0..255)}
        }
        $e | color apply $color --strip=$strip --no-reset=$no_reset
    }
}


# ---------------------------------------------------------------------------- #
#                                 container.nu                                 #
# ---------------------------------------------------------------------------- #



# use debug.nu *

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


# ---------------------------------------------------------------------------- #
#                                    core.nu                                   #
# ---------------------------------------------------------------------------- #

# use debug.nu *

# --------------------------------- commands --------------------------------- #

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

export def threads [
    ...threads: closure
] {
    $threads | par-each {|thread|
        do $thread
    }
    null # return null instead of par-each result
}


# ---------------------------------------------------------------------------- #
#                                   debug.nu                                   #
# ---------------------------------------------------------------------------- #

export alias `debug-builtin` = debug

const TYPE_ANSI = {
    fg: '#A0A0A0',
    bg: '#303030',
}

export def test [] {
    "test"
}

export def debug [x] {
    
    $env.config.color_config.shape_garbage = 'default'
    let span = (metadata $x).span
    let x_name = view span $span.start $span.end | nu-highlight
    let x_type = $"(ansi --escape $TYPE_ANSI): ($x | describe)(ansi reset)"
    print $"($x_name)($x_type) ="
    print ($x | debug-builtin)
}


# ---------------------------------------------------------------------------- #
#                                    dev.nu                                    #
# ---------------------------------------------------------------------------- #

export def run [
    --watch(-w): string
] {
    let r = { nu ./run.nu }
    match $watch {
        null => { do $r }
        $w => { watch -g $w ./ $r }
    }
}

export def `watch cargo` [] {
    if not ('Cargo.toml' | path exists) {
        error make -u { msg: "Cargo.toml not found in current directory" }
    }
    if ('run.nu' | path exists) {
        watch -g *.rs ./ { try { nu run.nu } catch { print -n ""}; print (separator) }
    } else {
        watch -g *.rs ./ { try { cargo build --release } catch { print -n "" }; print (separator) }
    }
}


# ---------------------------------------------------------------------------- #
#                                 dictionary.nu                                #
# ---------------------------------------------------------------------------- #

export def define [$phrase] {
    let result = td def $phrase | lines
    let type = $result | parse '{_}-----------{type}' | get type | str downcase
    $type
}

export def synonyms [$phrase] {
    td thes $phrase
}

export def antonyms [$phrase] {
    td thes $phrase
}


# ---------------------------------------------------------------------------- #
#                                     do.nu                                    #
# ---------------------------------------------------------------------------- #


export def `do thing` [] {
    let i = (((date now | format date "%f" | into int) mod 1000000) / 100) + 1
    print -n $"doing ('thing' | color cycle $i) for ($i)ms..."
    erase right
    print ""
    countup ($i * 1ms)
}

export def `do things` [] {
    loop {
        do thing
    }
}



# ---------------------------------------------------------------------------- #
#                                   format.nu                                  #
# ---------------------------------------------------------------------------- #


export def `format hex` [
    # --upper(-u)
    --width(-w): int
    --remove-prefix(-r)
]: int -> string {
    # let format = match $upper {
    #     true => 'upperhex'
    #     false => 'lowerhex'
    # }
    let format = 'upperhex'
    $in | each {|e|
        mut e = $e | format number | get $format
        if $width != null {
            $e = $e | str remove '0x' | fill -a r -c '0' -w $width
            $e = '0x' + $e
        }
        if $remove_prefix {
            $e = $e | str remove '0x'
        }
        $e
    }
}

export alias hex = format hex

export def `format bin` [
    --width(-w): int
    --remove-prefix(-r)
]: int -> string {
    let format = 'binary'
    $in | each {|e|
        mut e = $e | format number | get $format
        if $width != null {
            $e = $e | str remove '0b' | fill -a r -c '0' -w $width
            $e = '0b' + $e
        }
        if $remove_prefix {
            $e = $e | str remove '0b'
        }
        $e
    }
}


# ---------------------------------------------------------------------------- #
#                                    git.nu                                    #
# ---------------------------------------------------------------------------- #

export alias gsw = git switch
export alias gbr = git branch
export alias grh = git reset --hard
export alias gcl = git clean -fd

export def grst [] {
    git reset --hard
    git clean -fd
}

export def gpsh [] {
    git add .
    git commit -m "quick update"
    git push
}


# ---------------------------------------------------------------------------- #
#                                interpolate.nu                                #
# ---------------------------------------------------------------------------- #

def interpolate_record [
    start
    end
    t?: float = 0.5
] {
    for v in ($start | values | append ($end | values)) {
        if not ((($v | describe) == "int") or (($v | describe) == "float")) {
            error make {
                msg: "invalid type"
                label: {
                    text: "value must be numeric"
                    span: (metadata $v).span
                }
            }
        }
    }
    match $t {
        $t if $t <= 0 => $start
        $t if $t >= 1 => $end
        _ => {
            $start | items {|k v|
                mut new = $v + (($end | get $k) - $v) * $t
                if ($v | describe) == "int" {
                    $new = $new | into int
                }
                {$k: $new}
            } | into record
        }
    }
}

def interpolate_list [
    start
    end
    t?: float = 0.5
] {
    for v in ($start | append $end) {
        if not ((($v | describe) == "int") or (($v | describe) == "float")) {
            error make {
                msg: "invalid type"
                label: {
                    text: "value must be numeric"
                    span: (metadata $v).span
                }
            }
        }
    }
    match $t {
        $t if $t <= 0 => $start
        $t if $t >= 1 => $end
        _ => {
            $start | zip $end | each {|e|
                mut new_value = $e.0 + ($e.1 - $e.0) * $t
                if (($e.0 | describe) == "int") {
                    $new_value = $new_value | into int
                }
                $new_value
            }
        }
    }
}

export def interpolate [
    # start
    end
    t?: float = 0.5
] {
    let start = $in
    if ($start | describe) != ($end | describe) {
        error make {
            msg: "type mismatch"
            label: {
                text: "start and end must have the same types"
                span: (metadata $end).span
            }
        }
    }
    match ($start | describe) {
        $d if ($d | str starts-with "record") => (interpolate_record $start $end $t)
        $d if ($d | str starts-with "list") => (interpolate_list $start $end $t)
        _ => {
            error make {
                msg: "unsupported type"
                label: {
                    text: "start and end must be of a supported type (record or list)"
                    span: (metadata $start).span
                }
            }
        }
    }
}



export def `commands built-in` [] {
    commands| where command_type == built-in | select name description
}

export def `commands external` [] {
    commands | where command_type == external | select name description
}

export def `commands custom` [] {
    commands| where command_type == custom | select name description
}

export def aliases [] {
    commands | where command_type == alias | select name description
}

export def "commands plugin" [] {
    commands | where command_type == plugin | select name description
}

export def commands [] {
    help commands | reject params input_output search_terms is_const
}




# ---------------------------------------------------------------------------- #
#                                  monitor.nu                                  #
# ---------------------------------------------------------------------------- #

export def monitor [--interval(-i): duration = 1sec]: closure -> nothing {
    clear
    let task = $in
    let loading = [
        "⠇   ",
        "⠋   ",
        " ⠉  ",
        "  ⠉ ",
        "   ⠙",
        "   ⠸",
        "   ⠴",
        "  ⣀ ",
        " ⣀  ",
        "⠦   ",
    ] | color apply cyan
    let loading_len = $loading | length
    # mut cursor_start = cursor position
    mut term_size = term size
    let start_time = date now
    cursor off
    loop {
        let task_start_time = date now
        try {
            let result = do $task
            print $result
            while (((date now) - $task_start_time) < $interval) {
                let i = ((((date now) - $start_time) mod $interval) / $interval) * $loading_len | math floor
                let line = $"($loading | get $i)" | fill -a r -w (term size).columns
                print -n $"($line)\r"
            }
            # if (term size) != $term_size {
            #     $term_size = term size
            #     erase
            #     $cursor_start = cursor position
            # } else {
            #     cursor move-to $cursor_start
            # }
            if (term size) != $term_size {
                $term_size = term size
                clear
            }
            cursor home
        } catch {
            break;
        }
    }
    cursor on
}

export def `monitor disk` [--no-bar(-b), --all(-a)] {
    let task = match $all {
        true => { status disks --no-bar=($no_bar) }
        false => {
            let disks = sys disks | upsert display {|e| $"($e.mount) \(($e.device)\)"}
            let disk_choice = ($disks | input list -d display)
            { (status disks --no-bar=($no_bar)) | select $disk_choice.mount }
        }
    }
    $task | monitor
}

export def `monitor memory` [--no-bar(-b), --all(-a)] {
    let task = match $all {
        true => { status memory --no-bar=($no_bar) }
        false => {
            let mem_choice = ['RAM' 'Swap'] | input list
            { status memory --no-bar=($no_bar) | select $mem_choice }
        }
    }
    $task | monitor
}

export def `monitor ram` [--no-bar(-b)] {
    { status memory --no-bar=($no_bar) | select RAM } | monitor
}

export def `monitor banner` [] {
    { print banner } | monitor
}


# ---------------------------------------------------------------------------- #
#                                print-utils.nu                                #
# ---------------------------------------------------------------------------- #

export def `char block` [
    shade?: int = 4
] {
    match $shade {
        1 => "░"
        2 => "▒"
        3 => "▓"
        _ => "█"
    }
}

export def blocks [
    length: int
    --shade(-s): int = 4
] {
    "" | fill -c (char block $shade) -w $length
}

export def bar [
    value: float
    --length(-l): int = 12
    --fg-color(-f): any = 'white'
    --bg-color(-b): any = 'gray'
    --attr(-a): string
] {
    # asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $value
    let attr = match $attr {
        null => ""
        _ => $attr
    }
    let bar = ~/Projects/bar/target/release/bar.exe -l $length $value
    let ansi_color = {
        fg: ($fg_color | into rgb | rgb get-hex),
        bg: ($bg_color | into rgb | rgb get-hex),
        attr: $attr,
    }
    $bar | color apply $ansi_color
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

export def countdown [
    duration: duration
    --no-bar(-b)
    --bar-length(-l): int = 12
    --start-color(-s): any = white
    --end-color(-e): any = white
] {
    if $duration < 1ms {
        error make {
            msg: "invalid duration",
            label: {
                text: "must be greater than or equal to 1ms",
                span: (metadata $duration).span,
            }
        }
    }
    let start_time = date now
    let end_time = $start_time + $duration
    mut $remaining = $duration
    cursor off
    while $remaining > 0sec {
        let proportion = $remaining / $duration
        let color = ($start_color | into rgb) | interpolate ($end_color | into rgb) $proportion
        mut status = $"($remaining | round duration)" | color apply $color
        if not $no_bar {
            let bar = bar --length=$bar_length --fg-color $color ($remaining / $duration)
            $status = $"($bar) ($status)"
        }
        print -n $status
        erase right
        print -n "\r"
        $remaining = $end_time - (date now)
    }
    # print $"(ansi green)("Done")(erase right)(ansi reset)"
    # print -n $"(ansi reset)"
}

export def countup [
    duration: duration
    --no-bar(-b)
    --bar-length(-l): int = 12
    --start-color(-s): any = white
    --end-color(-e): any = white
] {
    if $duration < 1ms {
        error make {
            msg: "invalid duration",
            label: {
                text: "must be greater than or equal to 1ms",
                span: (metadata $duration).span,
            }
        }
    }
    let start_time = date now
    let end_time = $start_time + $duration
    mut $remaining = $duration
    cursor off
    while $remaining > 0sec {
        let proportion = $remaining / $duration
        let color = ($start_color | into rgb) | interpolate ($end_color | into rgb) $proportion
        mut status = $"(($duration - $remaining) | round duration)" | color apply $color
        if not $no_bar {
            let bar = bar --length=$bar_length --fg-color $color (($duration - $remaining) / $duration)
            $status = $"($bar) ($status)"
        }
        print -n $status
        erase right
        print -n "\r"
        $remaining = $end_time - (date now)
    }
    # print $"(ansi green)("Done")(erase right)(ansi reset)"
    # print -n $"(ansi reset)"
}


# ---------------------------------------------------------------------------- #
#                                 procedure.nu                                 #
# ---------------------------------------------------------------------------- #

# ╭────┬────╮
# │    │    │
# ├────┼────┤
# │    │    │
# ╰────┴────╯


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
        print ($"\n($name) successful" | color apply green)
        print (separator)
    } catch {
        print ($"\n($name) failed" | color apply red)
        print (separator)
    }
    cursor on
}

def left_margin [level] {
    match $level {
        0 => "",
        # $n => ('  ' + ('│     ' | repeat ($n - 1) | str join))
        $n => ('  ' + ('┆     ' | repeat ($n - 1) | str join))
    }
}

def print-task [name] {
    match ($env.PROCEDURE_LEVEL - 1) {
        0 => {
            print $name
        }
        # $n if $env.PROCEDURE_LEAF => {
        #     let left_margin = left_margin $n
        #     # print $"($left_margin)│"
        #     print $"($left_margin)├─→ ($name)"
        #     # print $"($left_margin)├─ ($name)"
        #     # print $"($left_margin)╰─→ ($name)"
        # }
        $n => {
            let left_margin = left_margin $n
            # print $"($left_margin)│"
            print $"($left_margin)├─→ ($name)"
            # print $"($left_margin)├─ ($name)"
            # print $"($left_margin)╰─→ ($name)"
        }
    }
}

def print-result [result] {
    let result = match $result {
        # success => {text: "Success", icon: "✔", color: green}
        # warning => {text: "Warning", icon: "", color: yellow}
        success => {text: "Success", icon: "✓", color: green}
        warning => {text: "Warning", icon: "!", color: yellow}
        error => {text: "Failed", icon: "×", color: red}
    }
    # debug $env.PROCEDURE_LEVEL
    match ($env.PROCEDURE_LEVEL - 1) {
        $n if ($env.PROCEDURE_LEAF and ($n >= 1)) => {()}
        0 => {
            print ($"  │" | color apply $result.color)
            print ($"  ╰─→ ($result.text)\n" | color apply $result.color)
            # print ($"($result.text)\n" | color apply $result.color)
        }
        # 1 => {
        #     let left_margin = left_margin 1
        #     # print ($left_margin + "│" + ($"    │" | color apply $color))
        #     # print ($left_margin + "│" + ($"←───╯ ($text)" | color apply $color))
        #     print ($left_margin + ($"╭────╯" | color apply $color))
        # }
        $n => {
            let left_margin = left_margin $n
            # print ($left_margin + "│" + ($"     │" | color apply $color))
            # print ($left_margin + "│" + ($"←────╯ ($text)" | color apply $color))
            print ($left_margin + ($"╭─────╯ ($result.icon)" | color apply $result.color))
            print ($left_margin + ($"│" | color apply $result.color))
            

            # print ($left_margin + ($"│" | color apply $color))
            # print ($left_margin + ($"╰─ ($text)" | color apply $color))
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
        $n => ($"(left_margin $n)" + ("│    ╰─ " + $message | color apply $color))
    }
    print $message
}


# ---------------------------------------------------------------------------- #
#                                 processes.nu                                 #
# ---------------------------------------------------------------------------- #


const MAX_NAME_LENGTH = 20
const MAX_NUM_PROCESSES = 25

export def get-applications [] {
    let curr_ps = ps -l | reject command cwd environment user_sid
    $curr_ps | where {|p| ((($curr_ps | where {|q| $p.pid == $q.ppid}) | length) > 0) or ($p.mem > 100MB) }
}

def choose_process [choices] {
    let choices = $choices | first $MAX_NUM_PROCESSES | upsert dis_name {|e|
        let name = match ($e.name | str length) {
            0 => "Unknown"
            $l if ($l <= $MAX_NAME_LENGTH) => $e.name
            $l => (($e.name | str substring 0..($MAX_NAME_LENGTH - 3)) + "...")
        }
        match $e.mem {
            $m if $m > 1GB => ($name | color apply red),
            $m if $m > 100MB => ($name | color apply yellow),
            $m if $m > 10MB => ($name | color apply green),
            $m if $m > 1MB => ($name | color apply blue),
        }
    }
    let w = $choices | get dis_name | strip length | math max
    let choices = $choices | upsert display {|e|
        $"($e.dis_name | fill -w $w) [($e.mem)] - ($e.start_time | date humanize)"
    }
    match ($choices | input list -d display) {
        null => {
            error make -u { msg: "no process selected" }
            return null
        }
        $c => $c
    }
}

def kill_process [
    process
    --force
] {
    print $"Closing ($process.name) \(($process.pid)\)..."
    kill --force=$force $process.pid
}

def close_by_name [
    apps
    process_name
    --all
    --force
] {
    
    let choices = $apps | where {|e| $e.name | str downcase | str contains ($process_name | str downcase)}
    match ($choices | length) {
        0 => {
            error make {
                msg: $"no processes found"
                label: {
                    text: "process not found"
                    span: (metadata $process_name).span
                }
            }
            return
        }
        1 => {
            let choice = $choices | first
            print $"Closing ($choice.pid)..."
            kill -f $choice.pid
        }
        _ => {
            match $all {
                true => {
                    for p in $choices {
                        kill_process $p --force=$force
                    }
                }
                false => {
                    let choice = choose_process $choices
                    kill_process $choice --force=$force
                }
            }
        }
    }
}

export def close [
    process?: any
    # --choose(-c)
    --all(-a)
    --force(-f)
] {
    let apps = get-applications | sort-by -r mem
    match ($process | describe) {
        nothing => {
            let choice = choose_process $apps
            kill_process $choice --force=$force
        }
        string => {
            close_by_name $apps $process --all=$all --force=$force
        }
        int => {
            kill $process --force=$force
        }
        _ => {
            error make {
                msg: "invalid process type"
                label: {
                    text: "invalid type"
                    span: (metadata $process).span
                }
            }
        }
    }
}


# ---------------------------------------------------------------------------- #
#                                   random.nu                                  #
# ---------------------------------------------------------------------------- #


export def `random color` [
    --hsv(-h)
    --dark(-d)
    --light(-l)
    --gray(-g)
] {
    if $dark and $light {
        error make -u { msg: "Cannot specify both --dark (-d) and --light (-l)" }
    }
    if not $hsv {
        match $gray {
            true => {
                let range = match _ {
                    _ if $dark => 0..95
                    _ if $light => 160..255
                    _ => 0..255
                }
                let v = random int $range
                {r: $v, g: $v, b: $v}
            }
            false => {
                let range = match _ {
                    _ if $dark => {r: 0..100, g: 0..100, b: 0..100}
                    _ if $light => {r: 128..255, g: 128..255, b: 128..255}
                    _ => {r: 0..255, g: 0..255, b: 0..255}
                }
                {
                    r: (random int $range.r)
                    g: (random int $range.g)
                    b: (random int $range.b)
                }
            }
        }
    } else {
        match $gray {
            true => {
                let range = match _ {
                    _ if $dark => 0.0..<0.3
                    _ if $light => 0.75..<1.0
                    _ => 0.0..<1.0
                }
                let v = random float $range
                {h: 0, s: 0.0, v: $v}
            }
            false => {
                let range = match _ {
                    _ if $dark => {h: 0..<360, s: 0.25..<1.0, v: 0.0..<0.4}
                    _ if $light => {h: 0..<360, s: 0.25..<1.0, v: 0.75..<1.0}
                    _ => {h: 0..<360, s: 0.0..<1.0, v: 0.0..<1.0}
                }
                {
                    h: (random int $range.h)
                    s: (random float $range.s)
                    v: (random float $range.v)
                }
            }
        }
    }
}


# ---------------------------------------------------------------------------- #
#                                  records.nu                                  #
# ---------------------------------------------------------------------------- #


# Given a record, produce a list of its keys.
export def keys [] {
    items {|key, _| $key}
}

# Given a record, iterate on each key while retaining the record structure.
export def `each key` [closure: closure] {
    items {|key, value|
        {(do $closure $key): $value}
    } | into record
}

# Given a record, iterate on each value while retaining the record structure.
export def `each value` [closure: closure] {
    items {|key, value|
    {$key: (do $closure $value)}
    } | into record
}


# ---------------------------------------------------------------------------- #
#                                    rgb.nu                                    #
# ---------------------------------------------------------------------------- #

# use container.nu [contain 'container print']

# Convert an RGB record to a hex string
export def `rgb get-hex` []: record<r: int, g: int, b: int> -> string {
    each {|e|
        let rgb = $e | each value {|v|
            if $v < 0 or $v > 255 {
                error make -u { msg: "RGB value out of range" }
            }
            $v | format hex -r -w 2
        }
        $"#($rgb.r)($rgb.g)($rgb.b)"
    }
}

# Convert a hex string to an RGB record
export def `into rgb` []: any -> record<r: int, g: int, b: int> {
    each {|e|
        match $e {
            $s if ($s | describe) == "string" => {match $s {
                "red"           => (red)
                "green"         => (green)
                "blue"          => (blue)
                "yellow"        => (yellow)
                "cyan"          => (cyan)
                "magenta"       => (magenta)
                "black"         => (black)
                "white"         => (white)
                "gray"          => (gray)
                "light_red"     => (light_red)
                "light_green"   => (light_green)
                "light_blue"    => (light_blue)
                "light_yellow"  => (light_yellow)
                "light_cyan"    => (light_cyan)
                "light_magenta" => (light_magenta)
                _ if ($e | str starts-with '#') and (($e | str length) == 7) => {
                    let parsed = $e | parse -r '#(?<r>[0-9a-fA-F]{2})(?<g>[0-9a-fA-F]{2})(?<b>[0-9a-fA-F]{2})' | first
                    $parsed | each value {|v| ('0x' + $v | into int)}
                }
                _ if ($e | str starts-with '0x') and (($e | str length) == 8) => {
                    let parsed = $e | parse -r '0x(?<r>[0-9a-fA-F]{2})(?<g>[0-9a-fA-F]{2})(?<b>[0-9a-fA-F]{2})' | first
                    $parsed | each value {|v| ('0x' + $v | into int)}
                }
                _ => {
                    error make -u { msg: "Invalid color string" }
                }
            }}
            $r if ($r | describe) == "record<r: int, g: int, b: int>" => {
                if ($r.r < 0 or $r.r > 255) or ($r.g < 0 or $r.g > 255) or ($r.b < 0 or $r.b > 255) {
                    error make -u { msg: "RGB value out of range" }
                }
                $r
            }
            $h if ($h | describe) == "record<h: int, s: float, v: float>" => {
                if ($h.h < 0 or $h.h >= 360) or ($h.s < 0 or $h.s > 1) or ($h.v < 0 or $h.v > 1) {
                    error make -u { msg: "HSV value out of range" }
                }
                $h | rgb from-hsv
            }
        }
        
    }
}

# Convert an RGB record to HSV
export def `rgb get-hsv` []: [
    record<r: int, g: int, b: int> -> record<h: int, s: float, v: float>
] {
    each {|e|
        let $e = $e | each value {|v|
            if $v < 0 or $v > 255 {
                error make -u { msg: "RGB value out of range" }
            }
            $v / 255.0
        }
        let cmax = [$e.r, $e.g, $e.b] | math max
        let cmin = [$e.r, $e.g, $e.b] | math min
        let delta = $cmax - $cmin
        let h = match $cmax {
            _ if $delta == 0 => 0,
            _ if $cmax == $e.r => ((($e.g - $e.b) / $delta) * 60),
            _ if $cmax == $e.g => ((($e.b - $e.r) / $delta + 2) * 60),
            _ if $cmax == $e.b => ((($e.r - $e.g) / $delta + 4) * 60),
            _ => 0
        }
        let h = ($h | into int) mod 360
        let s = if $cmax == 0 { 0.0 } else { $delta / $cmax }
        let v = $cmax
        { h: $h, s: $s, v: $v }
    }
}

export def `rgb from-hsv` []: [
    record<h: int, s: float, v: float> -> record<r: int, g: int, b: int>
] {
    each {|e|
        let c = $e.v * $e.s
        let x = $c * (1 - ((($e.h / 60) mod 2) - 1 | math abs))
        let m = $e.v - $c
        let rgb = match ($e.h / 60) {
            $h if $h < 1 => {r: $c, g: $x, b: 0},
            $h if $h < 2 => {r: $x, g: $c, b: 0},
            $h if $h < 3 => {r: 0, g: $c, b: $x},
            $h if $h < 4 => {r: 0, g: $x, b: $c},
            $h if $h < 5 => {r: $x, g: 0, b: $c},
            _ => {r: $c, g: 0, b: $x}
        }
        $rgb | each value {|v| (($v + $m) * 255 | into int)}
    }
}

export def `color query` [query: string] {
    let query = match $query {
        'red' => "4;9;"
        'green' => "4;10;"
        'yellow' => "4;11;"
        'blue' => "4;12;"
        'magenta' => "4;13;"
        'cyan' => "4;14;"
        'white' => "4;15;"
        'black' => "4;16;"
        'foreground' => "10;"
        'background' => "11;"
        $q => $q
    }
    (term query $'(ansi osc)($query)?(ansi st)' --prefix $'(ansi osc)($query)' --terminator (ansi st) | decode) | parse "rgb:{r}/{g}/{b}" | first | each value {|v| ('0x' + $v | into int) / 0xFFFF * 255.0 | into int }
}

export def red [] {
    # $env.COLORS.RED
    {r: 224, g: 108, b: 117}
}

export def green [] {
    # $env.COLORS.GREEN
    {r: 152, g: 195, b: 121}
}

export def yellow [] {
    # $env.COLORS.YELLOW
    {r: 229, g: 192, b: 123}
}

export def blue [] {    
    # $env.COLORS.BLUE
    {r: 97, g: 175, b: 239}
}

export def magenta [] {
    # $env.COLORS.MAGENTA
    {r: 198, g: 120, b: 221}
}

export def cyan [] {
    # $env.COLORS.CYAN
    {r: 86, g: 182, b: 194}
}

export def white [] {
    # $env.COLORS.WHITE
    {r: 220, g: 223, b: 228}
}

export def black [] {
    # $env.COLORS.BLACK
    {r: 24, g: 24, b: 24}
}

export def gray [] {
    # $env.COLORS.GRAY
    {r: 80, g: 80, b: 80}
}

export def foreground [] {
    # $env.COLORS.FOREGROUND
    {r: 220, g: 223, b: 228}
}

export def background [] {
    # $env.COLORS.BACKGROUND
    {r: 38, g: 38, b: 38}
}



# ---------------------------------------------------------------------------- #
#                                   round.nu                                   #
# ---------------------------------------------------------------------------- #

export def "round duration" [unit?]: duration -> duration {
    each { |e|
        let unit_time = match $unit {
            ns => 1ns,
            us => 1us,
            ms => 1ms,
            sec => 1sec,
            min => 1min,
            hr => 1hr,
            day => 1day,
            wk => 1wk,
            null => {
                match $e {
                    # _ if ($e mod 1day == 0sec) => 1wk,
                    # _ if ($e mod 1hr == 0sec) => 1day,
                    # _ if ($e mod 1min == 0sec) => 1hr,
                    # _ if ($e mod 1sec == 0sec) => 1min,
                    # _ if ($e mod 1ms == 0sec) => 1sec,
                    # _ if ($e mod 1us == 0sec) => 1ms,
                    # _ if ($e mod 1ns == 0sec) => 1us,
                    # _ => 1ns
                    _ if ($e < 1ms) => 1ns,
                    _ if ($e < 1sec) => 1us,
                    _ if ($e < 1min) => 1ms,
                    _ if ($e < 1hr) => 1sec,
                    _ if ($e < 1day) => 1min,
                    _ if ($e < 1wk) => 1hr,
                    _ => 1day
                }
            }
            _ => {
                throw "Invalid unit: $unit"
            }
        }
        let rounded_ns = ($e / $unit_time | math round) * $unit_time
        $rounded_ns | into duration
    }
}

export def round [] {
    each { |e|
        if ($e | describe) == "duration" {
            $e | round duration
        } else {
            $e | math round
        }
    }
}



# ---------------------------------------------------------------------------- #
#                                  shadows.nu                                  #
# ---------------------------------------------------------------------------- #

export alias config-nu-builtin = config nu

# Edit nu configurations.
export def `config nu` [
    --default(-d)   # Print the internal default `config.nu` file instead.
    --doc(-s)       # Print a commented `conifg.nu` with documentation instead.
    --builtin(-b)   # Edit the actual built-in `config.nu` file instead of the custom one.
] {
    if $default {
        config-nu-builtin --default
    } else if $doc {
        config-nu-builtin --doc | nu-highlight | less -R
    } else if $builtin {
        config-nu-builtin
    } else {
        cd ~/Projects/nushell-scripts
        code config.nu
    }
}

export alias ls-builtin = ls

# List the filenames, sizes, and modification times of items in a directory.
export def ls [
    --builtin(-b),      # Use the built-in ls command instead of the external one
    --all (-a),         # Show hidden files
    --full-paths (-f),  # display paths as absolute paths
    ...pattern: glob,   # The glob pattern to use.
] {
    let pattern = if ($pattern | is-empty) { [ '.' ] } else { $pattern }
    let table = (ls-builtin
        --all=$all
        --short-names=(not $full_paths)
        --full-paths=$full_paths
        ...$pattern
    )
    match $builtin {
        true => $table
        false => ($table | sort-by type name -i | grid -c)
    }
}


# ---------------------------------------------------------------------------- #
#                                   splash.nu                                  #
# ---------------------------------------------------------------------------- #

export def splash [color?: any = 'default', --shorten-by(-s): int = 1, --fill(-f)] {
    $in | contain -p "comfy" | div --background=$color --position 'c' --shorten-by=$shorten_by --fill=$fill | container print
}


# ---------------------------------------------------------------------------- #
#                                   status.nu                                  #
# ---------------------------------------------------------------------------- #


def severity-bar [proportion] {
    let input = $in
    match $proportion {
        _ if $proportion < 0.6 => (bar -f green $proportion)
        _ if $proportion < 0.8 => (bar -f yellow $proportion)
        _ => (bar -f red $proportion)
    }
}

def severity [severity] {
    let input = $in
    match $severity {
        _ if $severity < 0.6 => ($input | color apply green)
        _ if $severity < 0.8 => ($input | color apply yellow)
        _ => ($input | color apply red)
    }
}

def disk_str [disk, --no-bar(-b)] {
    let disk_label = $"($disk.mount)"
    let amount_used = $disk.total - $disk.free
    let proportion_used = $amount_used / $disk.total
    let percent_used = ($proportion_used * 100 | math round --precision 0)
    mut disk_status = $"($amount_used) \(($percent_used)%\)" | severity $proportion_used
    if not $no_bar {
        let disk_bar = severity-bar $proportion_used
        $disk_status = $"($disk_bar) ($disk_status)"
    }
    $disk_status | severity $proportion_used
}

def memory_str [memory, --no-bar(-b)] {
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    mut memory_status = $"($memory.used) \(($percent_used)%\)" | severity $proportion_used
    if not $no_bar {
        let memory_bar = severity-bar $proportion_used
        $memory_status = $"($memory_bar) ($memory_status)"
    }
    $memory_status | severity $proportion_used
}

def mem_swap_str [memory, --no-bar(-b)] {
    let proportion_used = $memory.'swap used' / $memory.'swap total'
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    mut memory_status = $"($memory.'swap used') \(($percent_used)%\)" | severity $proportion_used
    if not $no_bar {
        let memory_bar = severity-bar $proportion_used
        $memory_status = $"($memory_bar) ($memory_status)"
    }
    $memory_status | severity $proportion_used
}

export def `status disks` [--no-bar(-b)] {
    let disks = (sys disks)
    $disks | each { |disk| {$disk.mount: (disk_str --no-bar=($no_bar) $disk)} } | into record
}

export def `status memory` [--no-bar(-b)] {
    let memory = (sys mem)
    {
        RAM: (memory_str $memory --no-bar=($no_bar))
        Swap: (mem_swap_str $memory --no-bar=($no_bar))
    }
}

export alias memory = status memory
export alias ram = status memory
export alias disks = status disks


# ---------------------------------------------------------------------------- #
#                                    str.nu                                    #
# ---------------------------------------------------------------------------- #

export def `str remove` [
    substring: string
    --all(-a)
    --regex(-r)
    --multiline(-m)
] {
    each {|e| $e | str replace --all=$all --regex=$regex --multiline=$multiline $substring ''}
}


# ---------------------------------------------------------------------------- #
#                                   system.nu                                  #
# ---------------------------------------------------------------------------- #

# export def copy [] {

# }

export def shutdown [] {
    run-external 'shutdown' '/s' '/t' '0'
}

export def reboot [] {
    run-external 'shutdown' '/r' '/t' '0'
}

export alias restart = reboot


# ---------------------------------------------------------------------------- #
#                                   tools.nu                                   #
# ---------------------------------------------------------------------------- #


# Send a request to Wolfram Alpha and print the response
export def wa [...input: string] {
    let APPID = open ~/wolfram_appid.txt | str trim
    let question_string = $input | str join ' ' | url encode
    let url = (["https://api.wolframalpha.com/v1/result?appid=", $APPID, "&i=", $question_string] | str join)
    curl $url
}

export alias du = dust
export alias vim = nvim

export alias spewcap = ~/Projects/spewcap2/target/release/spewcap2.exe
export alias size = ~/Projects/size-converter/target/release/size-converter.exe

# export alias `highlight md` = ~/Projects/syntect-test/target/release/syntect-test.exe

# General purpose chat assistant
export alias chat = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/chat_prompt.txt

export alias `show me` = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/chat_prompt.txt 'Show me '

# export def chat [...prompt] {
#     alias cmd = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/chat_prompt.txt
#     let result = match $prompt {
#         [] => (cmd)
#         _ => (cmd ($prompt | str join ' '))
#     } | each {|delta|
#         # print -n $token
#         # sleep 100ms
#         # print $"\nDEBUG delta: ($delta | debug-builtin -v)"
#         $delta
#     } | reduce --fold "" {|delta, result|
#         let new_result = $result + $delta
#         let new_result_lines = $new_result | lines
#         let new_result_highlighted_lines = $new_result | highlight md | lines
#         let new_result_highlighted_lines = match (($new_result_lines | length) - ($new_result_highlighted_lines | length)) {
#             0 => $new_result_highlighted_lines
#             $n => ($new_result_highlighted_lines | append ($new_result_lines | last $n))
#         }
#         print -n "\r" ($new_result_highlighted_lines | last ($delta | lines | length) | str join "\n")
#         if ($delta | str ends-with "\n") {
#             print ""
#         }
#         $new_result
#     }
# }

# General purpose chat assistant
export alias gpt = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/gpt_prompt.txt

# Chat assistant for general teaching
export alias teach = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/teach_prompt.txt

export alias `what is` = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/chat_prompt.txt 'What is '

# Ask for recipes by providing ingredients and preferences
export alias chef = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/chef_prompt.txt

# Ask about Vim, Neovim, and vi motions.
export alias askvim = ~/Projects/rusty-gpt/target/release/rusty-gpt.exe -a ~/Arrowhead/Files/api_key.txt -p ~/Arrowhead/Files/Prompts/askvim_prompt.txt

# alias calc = ~/Projects/qalculate/qalc.exe -c
export alias qalc = ~/Projects/qalculate/qalc.exe -c
export alias calc = ~/kalc.exe
export alias kalc = ~/kalc.exe

export alias mix = ~/Projects/mix/target/release/mix.exe

export def timer [duration: duration] {
    countdown $duration
    "Done" | contain -p t | blink | splash green
    # print $"(ansi green)("Done")(erase right)(ansi reset)"
}


# ---------------------------------------------------------------------------- #
#                                   update.nu                                  #
# ---------------------------------------------------------------------------- #


export def `update imports` [] {
    procedure new-task "Updating module imports" {
        procedure new-task "Creating new mod file" {
            if ($env.IMPORTS_FILE | path exists) {
                rm $env.IMPORTS_FILE
            } else {
                touch $env.IMPORTS_FILE
            }
        }
        procedure new-task "Writing module imports to mod file" {
            let modules = (ls-builtin ~/Projects/nushell-scripts/modules/ | sort-by type | get name | path basename)
            for m in $modules {
                $"use modules/($m) *\n" | save -a $env.IMPORTS_FILE
            }
        }
    }
}


# ---------------------------------------------------------------------------- #
#                                 variables.nu                                 #
# ---------------------------------------------------------------------------- #

export def `var update` [new_values?: record = {}] {
    touch $env.VARS_FILE
    let vars = open $env.VARS_FILE
    let updated = $vars | merge $new_values
    $updated | to toml | save -f $env.VARS_FILE
}

export def `var save` [name: string] {
    let value = $in
    touch $env.VARS_FILE
    let vars = open $env.VARS_FILE
    let updated = $vars | upsert $name $value
    $updated | to toml | save -f $env.VARS_FILE
}

export def `var load` [name?: string] {
    if not ($env.VARS_FILE | path exists) {
        error make {
            msg: "vars file does not exist"
            label: {
                text: "create a vars file first with `var update`"
                span: (metadata $env.VARS_FILE).span
            }
        }
    }
    let vars = open $env.VARS_FILE
    if $name != null {
        $vars | get -i $name
    } else {
        $vars
    }
}

export def `var delete` [name: string] {
    if not ($env.VARS_FILE | path exists) {
        error make {
            msg: "vars file does not exist"
            label: {
                text: "create a vars file first with `var update`"
                span: (metadata $env.VARS_FILE).span
            }
        }
    }
    let vars = open $env.VARS_FILE
    $vars | reject $name | to toml | save -f $env.VARS_FILE
}


# ---------------------------------------------------------------------------- #
#                                  version.nu                                  #
# ---------------------------------------------------------------------------- #

# plugin use semver


export alias `builtin version-check` = version check

export def "version check" [] {
    let nu_version = var load nu_version
    if $nu_version == null {
        version full-check
    } else if $nu_version.latest == null {
        version full-check
    } else if ((date now) > ($nu_version.last_checked + 1day)) {
        version full-check
    } else {
        let installed = version | get version
        let current = ($nu_version.latest == $installed)
        {
            channel: "release",
            current: $current,
            latest: $nu_version.latest,
        }
    }
}

export def `version full-check` [] {
    let installed = version | get version
    let info = cargo info -q nu
    let latest = $info | lines | parse "{key}: {value}" | where key == "version" | get value | first | str trim
    # let latest = cargo search -q --limit 1 nu | lines | parse 'nu = "{version}"{_}' | first | get version
    let current = ($latest == $installed)
    var update {nu_version: {latest: $latest, last_checked: (date now)}} 
    {
        channel: "release",
        current: $current,
        latest: $latest,
    }
}


# ----------------------------------------------------------------

export def show [file] {
    open $file | highlight
}
