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
    [idx_renamed            ($"(ansi purple)+R(ansi reset)")]
    [idx_type_changed       ($"(ansi yellow)+T(ansi reset)")]
    [wt_untracked           ($"(ansi green)U(ansi reset)")]
    [wt_modified            ($"(ansi blue)M(ansi reset)")]
    [wt_deleted             ($"(ansi red)D(ansi reset)")]
    [wt_type_changed        ($"(ansi yellow)T(ansi reset)")]
    [wt_renamed             ($"(ansi purple)R(ansi reset)")]
    [conflicts              ($"(ansi red_bold)C(ansi reset)")]
    [stashes                ($"(ansi magenta)S(ansi reset)")]
    [ahead                  ($"(ansi green)↑(ansi reset)")]
    [behind                 ($"(ansi red)↓(ansi reset)")]
]

const STATES = {
    'M': {display: modified, state_style: blue, file_style: default}
    'A': {display: added, state_style: green, file_style: default}
    'D': {display: deleted, state_style: red, file_style: attr_strike}
    'R': {display: renamed, state_style: yellow, file_style: default}
    'C': {display: conflict, state_style: purple, file_style: red}
    '?': {display: untracked, state_style: default, file_style: default}
}

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

# ---------------------------------------------------------------------------- #

def display_entry [e type] {
    let state = $STATES | get ($e | get $type)
    let state_str = $state.display | paint with $state.state_style
    let colors = {dirname: 'green_dimmed', basename: 'cyan', separator: 'cyan_dimmed'}
    let file_str = $e.name | path highlight $colors -l | paint with $state.file_style
    { state: $state_str, name: $file_str }
}

export def `git stat` [] {
    let entries = git status --porcelain | lines | parse -r '^(?<idx>.)(?<wt>.) (?<name>.+)$' | str trim
    let staged = $entries | where {|e| $e.idx != '' and $e.idx != '?'}
    let unstaged = $entries | where {|e| $e.wt != '' and $e.wt != '?'}
    let untracked = $entries | where {|e| $e.idx == '?' and $e.wt == '?'}

    print "Changes to be committed:"
    let staged = $staged | each {|e| display_entry $e 'idx' }
    print $staged ""

    print "Changes not staged for commit:"
    let unstaged = $unstaged | each {|e| display_entry $e 'wt' }
    print $unstaged ""

    let state = $STATES | get '?'
    let untracked = $untracked | each {|e|
        ls -l $e.name | first | select name size created | update name {|row|
            $e.name | path highlight -l {
                dirname: 'green_dimmed'
                basename: 'yellow'
                separator: 'cyan_dimmed'
            } | paint with $state.file_style
        }
    }
    if ($untracked | length) > 0 {
        print "Untracked files:"
        print $untracked
    }
}
