
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

