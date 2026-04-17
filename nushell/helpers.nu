use modules/status.nu ['status memory' 'status uptime' 'status startup']
use modules/round.nu 'round duration'
use modules/paint.nu [main 'paint path']
use modules/git.nu GSTAT_ICONS
use modules/jobs.nu 'job recv-all'

export def pre-prompt []: nothing -> list<closure> {
    [
        { $env.EXECUTION_TIME = try { (date now) - $env.EXECUTION_START } }
        { job spawn { try { gstat | job send 0 --tag 42 } } }
    ]
}
export def pre-execution []: nothing -> list<closure> {
    [
        { if $env.FIRST_PROMPT { $env.FIRST_PROMPT = false } }
        { $env.EXECUTION_START = date now }
    ]
}

export def prompt-left []: nothing -> string {
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-dir }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }
    $dir | paint path
}

export def prompt-right []: nothing -> string {
    mut info = [(status memory -i)]
    if $env.FIRST_PROMPT {
        $env.FIRST_PROMPT = false
        $info = [(status uptime -i) (status startup -i)] ++ $info
    }
    try {
        let git_status = job recv-all --tag 42 --timeout 50ms | last
        if $git_status.repo_name != no_repository {
            let values = $GSTAT_ICONS | upsert num {|e| $git_status | get $e.value}
            let num_changes = $values | get num | math sum
            let branch_color = match $git_status {
                {conflicts: $c} if $c > 0 => 'red_bold'
                {ahead: $a} if $a == $num_changes => 'green_bold'
                _ => 'yellow_bold'
            }
            let values = $values | where num > 0 | each { |e| $"($e.display) ($e.num)" }
            let branch = $git_status.branch
            mut git_info = [$"(ansi $branch_color)(char -u f062c) ($branch)(ansi reset)"]
            if not ($values | is-empty) {
                $git_info = $git_info ++ $values
            }
            $info = $git_info ++ $info
        }
    }
    try {
        if $env.EXECUTION_TIME > 100ms {
            let exec_time_str = $"(char -u f520)  ($env.EXECUTION_TIME | round duration -w | paint grey69)"
            $info = [$exec_time_str] ++ $info
        }
    }
    try {
        if $env.SSH_CONNECTION != null {
            let hostname = sys host | get hostname | str replace '.local' '' | paint magenta
            $info = [$hostname] ++ $info
        }
    }
    (ansi reset) + ($info | grid | lines | first)
}

export def prompt-indicator [char: string = '>']: nothing -> string {
    # let color = (if (is-admin) { ansi red } else { ansi green })
    # $"(ansi reset)($color)($char)(ansi reset) "
    if (is-admin) {
        "!> " | paint red_bold
    } else {
        $"($char) " | paint cyan_bold
    }
}

export def `load ls-colors` [] {
    let ls_colors_file = $nu.data-dir | path join '.ls-colors'
    if ($ls_colors_file | path exists) {
        open $ls_colors_file
    } else if not (which vivid | is-empty) {
        print "generating LS_COLORS with vivid"
        let ls_colors = vivid generate ($nu.data-dir | path join 'ls-colors.yaml')
        $ls_colors | save $ls_colors_file
        $ls_colors
    } else {
        warn "vivid not found"
    }
}

export def `load keys` [file: path]: nothing -> record {
    if ($file | path exists) {
        open $file | items {|k, v|
            {($k | str upcase): $v}
        } | into record
    } else {
        warn $"($file) not found"
    }
}

export def `find program` [options: list<string>] {
    let found = $options | skip until {|e| which $e | is-not-empty } | first
    if $found == null {
        warn $"None of the options were found: ($options)"
    } else {
        $found
    }
}

export def warn [message: string]  {
    print -e $"(ansi yellow)warning:(ansi reset) ($message)"
}
