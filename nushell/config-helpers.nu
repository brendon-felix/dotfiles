

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
            let values = $GSTAT_ICONS | upsert num {|row| $git_status | get $row.value}
            let num_changes = $values | get num | math sum
            let branch_color = if $num_changes > 0 {
                if $git_status.conflicts > 0  or $git_status.behind > 0 {
                    'red_bold'
                } else if $git_status.ahead == $num_changes {
                    'green_bold'
                } else {
                    'yellow_bold'
                }
            } else {
                'green_bold'
            }
            let values = $values
                | where num > 0
                | each { |row| $"($row.display) ($row.num)" }
            let branch = $git_status.branch
            mut git_info = [
                $"(ansi $branch_color)(char -u f062c)
                ($branch)(ansi reset)"
            ]
            if not ($values | is-empty) {
                $git_info = $git_info | append $values
            }
            $info = $info | prepend $git_info
        }
    }
    # try {
    #     if $env.CMD_EXECUTION_TIME != null {
    #         let color = match $env.CMD_EXECUTION_TIME {
    #             _ if $env.CMD_EXECUTION_TIME < 1sec => 'green'
    #             _ if $env.CMD_EXECUTION_TIME < 10sec => 'yellow'
    #             _ => 'red'
    #         }
    #         $info = $info | prepend ($"took ($env.CMD_EXECUTION_TIME | round duration)" | paint $color)
    #     }
    # }
    (ansi reset) + ($info | grid | lines | first)
}

export def `generate prompt-indicator` [char: string = '>']: nothing -> string {
    let color = (if (is-admin) { ansi red } else { ansi green })
    $"(ansi reset)($color)($char)(ansi reset) "
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
