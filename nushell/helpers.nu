

use modules/status.nu ['status memory' 'status uptime' 'status startup']
use modules/round.nu 'round duration'
use modules/path.nu 'path highlight'
use modules/paint.nu main
use modules/git.nu GSTAT_ICONS

export def `generate prompt-left` []: nothing -> string {
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }
    $dir | path highlight
}

# export def `generate prompt-right` [] {
#     date now | format date "%a-%d %r"
# }

export def `generate prompt-right` []: nothing -> string {
    mut info = [(status memory -i)]
    if $env.FIRST_PROMPT {
        $env.FIRST_PROMPT = false
        $info = $info | prepend [(status uptime -i) (status startup -i)]
    }
    try {
        let git_status = job recv --all --tag 42 --timeout 50ms | last
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
                $git_info = $git_info | append $values
            }
            $info = $info | prepend $git_info
        }
    }
    try {
        if $env.CMD_EXECUTION_TIME > 100ms {
            let exec_time_str = $"(char -u f520)  ($env.CMD_EXECUTION_TIME | round duration -w | paint grey69)"
            $info = $info | prepend $exec_time_str
        }
    }
    (ansi reset) + ($info | grid | lines | first)
}

export def `generate prompt-indicator` [char: string = '>']: nothing -> string {
    # let color = (if (is-admin) { ansi red } else { ansi green })
    # $"(ansi reset)($color)($char)(ansi reset) "
    if (is-admin) {
        "!> " | paint red_bold
    } else {
        $"($char) " | paint green_bold
    }
}

export def ls-colors [] {
    let ls_colors_file = $nu.data-dir | path join '.ls-colors'
    if ($ls_colors_file | path exists) {
        open $ls_colors_file
    } else if not (which vivid | is-empty) {
        print "generating LS_COLORS with vivid"
        let ls_colors = vivid generate ($nu.data-dir | path join 'ls-colors.yaml')
        $ls_colors | save $ls_colors_file
        $ls_colors
    } else {
        print -e $"(ansi yellow)vivid not found, skipping loading LS_COLORS(ansi reset)"
        null
    }
}

export def get-keys [file: path]: nothing -> record {
    if ($file | path exists) {
        open $file | items {|k, v|
            {($k | str upcase): $v}
        } | into record
    } else {
        print -e $"(ansi yellow)keys.toml not found, skipping loading API keys(ansi reset)"
        null
    }
}
