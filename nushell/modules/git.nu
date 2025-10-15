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
    let entries = git status --porcelain | lines | parse -r '^(?<idx>.)(?<wt>.) (?<name>.+)$' | str trim

    let staged = $entries | where {|e| $e.idx != '' and $e.idx != '?'}
    if ($staged | length) > 0 {
        print "Changes to be committed:"
        let staged = $staged | each {|e| display_entry $e 'idx' }
        print $staged ""
    }

    let unstaged = $entries | where {|e| $e.wt != '' and $e.wt != '?'}
    if ($unstaged | length) > 0 {
        print "Changes not staged for commit:"
        let unstaged = $unstaged | each {|e| display_entry $e 'wt' }
        print $unstaged ""
    }

    let untracked = $entries | where {|e| $e.idx == '?' and $e.wt == '?'}
    if ($untracked | length) > 0 {
        print "Untracked files:"
        let untracked = $untracked | each {|e| (display_entry $e 'wt').name }
        print $untracked ""
    }
}
