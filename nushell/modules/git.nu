
# ---------------------------------------------------------------------------- #
#                                    git.nu                                    #
# ---------------------------------------------------------------------------- #

use path.nu 'path highlight'

export const GSTAT_ICONS = [
    {value: idx_added_staged, display: $"(ansi green)+A:(ansi reset)"}
    {value: idx_modified_staged, display: $"(ansi blue)+M:(ansi reset)"}
    {value: idx_deleted_staged, display: $"(ansi red)+D:(ansi reset)"}
    {value: idx_renamed, display: $"(ansi purple)+R:(ansi reset)"}
    {value: idx_type_changed, display: $"(ansi yellow)+T:(ansi reset)"}
    {value: wt_untracked, display: $"(ansi green)U:(ansi reset)"}
    {value: wt_modified, display: $"(ansi blue)M:(ansi reset)"}
    {value: wt_deleted, display: $"(ansi red)D:(ansi reset)"}
    {value: wt_type_changed, display: $"(ansi yellow)T:(ansi reset)"}
    {value: wt_renamed, display: $"(ansi purple)R:(ansi reset)"}
    {value: conflicts, display: $"(ansi red_bold)C:(ansi reset)"}
    {value: stashes, display: $"(ansi magenta)S:(ansi reset)"}
    {value: ahead, display: $"(ansi green)↑:(ansi reset)"}
    {value: behind, display: $"(ansi red)↓:(ansi reset)"}
]

const STATES = {
    'M': {display: modified, state_style: blue, file_style: default}
    'A': {display: added, state_style: green, file_style: default}
    'D': {display: deleted, state_style: red, file_style: attr_strike}
    'R': {display: renamed, state_style: yellow, file_style: default}
    'C': {display: conflict, state_style: purple, file_style: red}
    '?': {display: untracked, state_style: default, file_style: yellow}
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
    let state_str = $"(ansi $state.state_style)($state.display)(ansi reset)"
    let file_str = $"(ansi $state.file_style)($e.file | path highlight)(ansi reset)"
    { state: $state_str, file: $file_str }
}

export def `git stat` [] {
    let entries = git status --porcelain | lines | parse -r '^(?<idx>.)(?<wt>.) (?<file>.+)$' | str trim
    let staged = $entries | where {|e| $e.idx != '' and $e.idx != '?'}
    let unstaged = $entries | where {|e| $e.wt != '' and $e.wt != '?'}
    let untracked = $entries | where {|e| $e.idx == '?' and $e.wt == '?'}

    print "Changes to be committed:"
    let staged = $staged | each {|e| display_entry $e 'idx' }
    print $staged ""

    print "Changes not staged for commit:"
    let unstaged = $unstaged | each {|e| display_entry $e 'wt' }
    print $unstaged ""

    let untracked = $untracked | each {|e|
        let state = $STATES | get '?'
        $"(ansi $state.file_style)($e.file)(ansi reset)"
    }
    if ($untracked | length) > 0 {
        print "Untracked files:"
        print $untracked
    }
}
