
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

