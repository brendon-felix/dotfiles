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

export def main [
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