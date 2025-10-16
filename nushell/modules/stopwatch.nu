# ---------------------------------------------------------------------------- #
#                                 stopwatch.nu                                 #
# ---------------------------------------------------------------------------- #

use round.nu 'round duration'

export def --env `stopwatch start` []: nothing -> int {
    let id = $env.STOPWATCH_ID
    $env.STOPWATCH_ID = $id + 1
    $env.STOPWATCHES = $env.STOPWATCHES | append {id: $id start: (date now)}
    $id
}

export def --env `stopwatch measure` [id?: int = 0]: nothing -> duration {
    let entry = try { $env.STOPWATCHES | where id == $id | first } catch {
        error make {
            msg: "invalid stopwatch id"
            label: {
                text: $"no stopwatch found with id ($id)",
                span: (metadata $id).span
            }
        }
    }
    (date now) - $entry.start | round duration
}

export def `stopwatch list` [] {
    match ($env.STOPWATCHES | length) {
        0 => {}
        _ => $env.STOPWATCHES
    }
}

export def --env `stopwatch stop` [
    id?: int
    --all(-a)
] {
    if $all {
        if ($env.STOPWATCHES | is-empty) {
            error make -u {msg: "no running stopwatches"}
        } else {
            $env.STOPWATCHES = []
        }
    } else {
        let id = match $id {
            _ if ($env.STOPWATCHES | is-empty) => {
                error make -u {msg: "no running stopwatches"}
            }
            null => ($env.STOPWATCHES | last | get id)
            $i if $i in ($env.STOPWATCHES | get id) => $i
            _ => {
                error make {
                    msg: "invalid stopwatch id"
                    label: {
                        text: $"no stopwatch found with id ($id)",
                        span: (metadata $id).span
                    }
                }
            }
        }
        let entry = $env.STOPWATCHES | where id == $id | first
        let duration = (date now) - $entry.start | round duration
        $env.STOPWATCHES = $env.STOPWATCHES | where id != $id
        $duration
    }
}
