# ---------------------------------------------------------------------------- #
#                                    core.nu                                   #
# ---------------------------------------------------------------------------- #

use debug.nu *

use std null-device

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

# ---------------------------------- record ---------------------------------- #

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

# ---------------------------------- string ---------------------------------- #

export def `str remove` [
    substring: string
    --all(-a)
    --regex(-r)
    --multiline(-m)
] {
    each {|e| $e | str replace --all=$all --regex=$regex --multiline=$multiline $substring ''}
}

# ------------------------------------ int ----------------------------------- #

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


# --------------------------------- commands --------------------------------- #

export def `suppress all` []: closure -> nothing {
    do $in o+e> (null-device)
}

export def `suppress stderr` []: closure -> nothing {
    do $in e> (null-device)
}

export alias `suppress err` = `suppress stderr`

export def `suppress stdout` []: closure -> nothing {
    do $in o+e> (null-device)
}

# --------------------------------- variables -------------------------------- #

export def `var update` [new_values: record] {
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
