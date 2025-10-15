# ---------------------------------------------------------------------------- #
#                                    git.nu                                    #
# ---------------------------------------------------------------------------- #

use paint.nu [main 'paint with']
use path.nu 'path highlight'

export const GSTAT_ICONS = [
    [value                  display];
    [idx_added_staged       ($"(ansi green)+A(ansi reset)")]
    [idx_modified_staged    ($"(ansi blue)+M(ansi reset)")]
    [idx_deleted_staged     ($"(ansi red)+D(ansi reset)")]
    [idx_renamed            ($"(ansi cyan)+R(ansi reset)")]
    [idx_type_changed       ($"(ansi yellow)+T(ansi reset)")]
    [wt_untracked           ($"(ansi green)U(ansi reset)")]
    [wt_modified            ($"(ansi blue)M(ansi reset)")]
    [wt_deleted             ($"(ansi red)D(ansi reset)")]
    [wt_type_changed        ($"(ansi yellow)T(ansi reset)")]
    [wt_renamed             ($"(ansi cyan)R(ansi reset)")]
    [conflicts              ($"(ansi red_bold)C(ansi reset)")]
    [stashes                ($"(ansi purple)S(ansi reset)")]
    [ahead                  ($"(ansi green)↑(ansi reset)")]
    [behind                 ($"(ansi red)↓(ansi reset)")]
]

const STATES = {
    'M': {display: modified, style: blue}
    'A': {display: added, style: green}
    'D': {display: deleted, style: red}
    'R': {display: renamed, style: yellow}
    'C': {display: conflict, style: purple}
    '?': {display: untracked, style: default}
}

export alias gsw = git switch
export alias gbr = git branch
export alias grh = git reset --hard
export alias grh = git reset --soft
export alias gcl = git clean -fd
export alias gplr = ^git pull --rebase

export def grst [] {
    git reset --hard
    git clean -fd
}

export def gpsh [] {
    git add .
    git commit -m "quick update"
    git push
}

# ---------------------------------------------------------------------------- #

def display_entry [e type] {
    let state = $STATES | get ($e | get $type)
    let state_str = $state.display | paint with $state.style
    let path_colors = {dirname: 'green_dimmed', basename: 'cyan', separator: 'cyan_dimmed'}
    let file_str = $e.name | path highlight $path_colors -l
    { state: $state_str, name: $file_str }
}

export def `git stat` [] {
    let gstat = gstat
    if $gstat.repo_name == no_repository {
        error make -u {msg: "Not a git repository"}
    }
    let fetch = git fetch | complete
    if not ($fetch.stdout | is-empty) and $fetch.exit_code == 0 {
        print $"Fetched updates from ($gstat.remote | paint blue)" ""
    }
    print $"On branch ($gstat.branch | paint cyan)"

    if $gstat.remote != '' {
        match $gstat {
            {behind: 0, ahead: 0} => {
                print $"  which is ('up to date' | paint green) with ($gstat.remote | paint green)."
            }
            {behind: $b, ahead: 0} => {
                print $"  which is ('behind' | paint yellow) ($gstat.remote | paint green) by ($b | paint purple)."
            }
            {behind: 0, ahead: $a} => {
                print $"  which is ('ahead' | paint green) of ($gstat.remote | paint yellow) by ($a | paint purple)."
            }
            {behind: $b, ahead: $a} => {
                print $"  which is ('ahead' | paint green) of ($gstat.remote | paint yellow) by ($a | paint purple) and ('behind' | paint yellow) by ($b | paint purple)."
            }
        }
    }

    print ""

    let entries = git status --porcelain | lines | parse -r '^(?<idx>.)(?<wt>.) (?<name>.+)$' | str trim

    if ($entries | is-empty) {
        print $"Nothing to commit - working tree ('clean' | paint green)"
        return
    }

    let staged = $entries | where {|e| $e.idx != '' and $e.idx != '?'}
    let has_staged = not ($staged | is-empty)
    if $has_staged {
        print $"Changes ('staged' | paint green) for commit:"
        let staged = $staged | each {|e| display_entry $e 'idx' }
        print $staged ""
    }

    let unstaged = $entries | where {|e| $e.wt != '' and $e.wt != '?'}
    let has_unstaged = not ($unstaged | is-empty)
    if $has_unstaged {
        print $"Changes ('not staged' | paint yellow) for commit:"
        let unstaged = $unstaged | each {|e| display_entry $e 'wt' }
        print $unstaged ""
    }

    let untracked = $entries | where {|e| $e.idx == '?' and $e.wt == '?'}
    let has_untracked = not ($untracked | is-empty)
    if $has_untracked {
        print "Untracked files:"
        let untracked = $untracked | each {|e| (display_entry $e 'wt').name }
        print $untracked ""
    }

    # if not $has_staged and ($has_unstaged or $has_untracked) {
    #     print "No changes added to commit"
    # }
}
