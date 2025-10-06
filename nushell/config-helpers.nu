

use modules/status.nu 'status memory'
use modules/path.nu 'path highlight'
use modules/git.nu GSTAT_ICONS

export def `generate prompt-left` [] {
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

export def `generate prompt-right` [] {
    mut info = [(status memory)]
    try {
        let git_status = job recv --all --timeout 50ms | last
        if $git_status.repo_name != no_repository {
            let values = $GSTAT_ICONS
            let values = $values | upsert num {|row| $git_status | get $row.value}
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
                | where { |row| $row.num > 0}
                | each { |row| $"($row.display) ($row.num)" }
            let branch = $git_status.branch
            mut git_info = [$"(ansi $branch_color)(char -u f062c) ($branch)(ansi reset)"]
            if not ($values | is-empty) {
                $git_info = $git_info | append $values
            }
            $info = $info | prepend $git_info
        }
    }
    $info | grid | lines | first
}

export def `generate prompt-indicator` [] {
    let color = (if (is-admin) { ansi red } else { ansi green })
    let char = '>'
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
        null
    }
}

export def --env get-keys [file: path]: nothing -> record {
    if ($file | path exists) {
        open ~/Arrowhead/Files/keys.toml | items {|k, v|
            {($k | str upcase): $v}
        } | into record
    } else {
        print -e "keys.toml not found, skipping loading API keys"
        {}
    }
}
