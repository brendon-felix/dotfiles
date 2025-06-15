# ---------------------------------------------------------------------------- #
#                                    core.nu                                   #
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