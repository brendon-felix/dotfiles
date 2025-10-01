
# ---------------------------------------------------------------------------- #
#                                    git.nu                                    #
# ---------------------------------------------------------------------------- #

export alias gsw = git switch
export alias gbr = git branch
export alias grh = git reset --hard
export alias gcl = git clean -fd

export def grst [] {
    git reset --hard
    git clean -fd
}

export def gpsh [] {
    git add .
    git commit -m "quick update"
    git push
}

export def `git stat` [] {
    let status = git status --porcelain | lines | parse -r '^(?<staged>.)(?<unstaged>.) (?<file>.+)$' | str trim
    let staged = $status | where staged != ''
    print "Changes to be committed:"
    for entry in $staged {
        match $entry.staged {
            'M' => { print $"  (ansi blue)Modified:(ansi reset) (ansi green)($entry.file)(ansi reset)" }
            'A' => { print $"  (ansi green)Added:(ansi reset) (ansi green)($entry.file)(ansi reset)" }
            'D' => { print $"  (ansi red)Deleted:(ansi reset) (ansi green)(ansi attr_strike)($entry.file)(ansi reset)" }
            'R' => { print $"  (ansi yellow)Renamed:(ansi reset) (ansi green)($entry.file)(ansi reset)" }
            'C' => { print $"  (ansi magenta)Copied:(ansi reset) (ansi green)($entry.file)(ansi reset)" }
            # '?' => { print $"  (ansi cyan)Untracked:(ansi reset) ($entry.file)" }
            '?' => { } # Untracked files cannot be staged, so ignore this case
            _ => { print $"  (ansi gray)Unknown:(ansi reset) ($entry.file)" }
        }
    }
    # let staged_display = $staged | where staged != '?' | each { |entry|
    #     match $entry.staged {
    #         'M' => { display: Modified, color: blue, file_style: null }
    #         'A' => { display: Added, color: green, file_style: null }
    #         'D' => { display: Deleted, color: red, file_style: attr_str }
    #         'R' => { display: Renamed, color: yellow, file_style: null }
    #         'C' => { display: Copied, color: purple, file_style: null }
    #         _ => { display: Unknown, color: gray, file_style: null }
    #     }
    # }
    # for entry in $staged_display {
    # }
    print ""
    print "Changes not staged for commit:"
    let unstaged = $status | where unstaged != ''
    mut untracked = []
    for entry in $unstaged {
        match $entry.unstaged {
            'M' => { print $"  (ansi blue)Modified:(ansi reset) ($entry.file)" }
            'A' => { print $"  (ansi green)Added:(ansi reset) ($entry.file)" }
            'D' => { print $"  (ansi red)Deleted:(ansi reset) (ansi attr_strike)($entry.file)(ansi reset)" }
            'R' => { print $"  (ansi yellow)Renamed:(ansi reset) ($entry.file)" }
            'C' => { print $"  (ansi magenta)Copied:(ansi reset) ($entry.file)"  }
            # '?' => { print $"  (ansi cyan)Untracked:(ansi reset) ($entry.file)"  }
            '?' => { $untracked = $untracked | append $entry }
            _ => { print $"  (ansi gray)Unknown:(ansi reset) ($entry.file)"  }
        }
    }
    if ($untracked | length) > 0 {
        print ""
        print "Untracked files:"
        for entry in $untracked {
            print $"  (ansi cyan)Untracked:(ansi reset) (ansi yellow)($entry.file)(ansi reset)"
        }
    }
}
