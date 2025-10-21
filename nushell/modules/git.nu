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

def "nu-complete git log" [] {
    git log -n 32 --pretty=%h»¦«%s | lines | split column "»¦«" value description
    | each {|x| $x | update value $"($x.value)"}
}
def "nu-complete git branches" [] {
    git branch | lines | where {|x| not ($x | str starts-with '*')} | each {|x| $"($x|str trim)"}
}
export def --wrapped grh [
    commit?: string@"nu-complete git log"
    ...rest
] {
    if ($commit | is-empty) { ^git reset --hard ...$rest } else { ^git reset --hard $commit ...$rest }
}
export def --wrapped grs [
    commit?: string@"nu-complete git log"
    ...rest
] {
    if ($commit | is-empty) { ^git reset --soft ...$rest } else { ^git reset --soft $commit ...$rest }
}
export def --wrapped gsw [
    branch: string@"nu-complete git branches"
    ...rest
] {
    if ($branch | is-empty) { ^git switch ...$rest } else { ^git switch $branch ...$rest }
}
export def --wrapped gbD [
    branch: string@"nu-complete git branches"
    ...rest
] {
    if ($branch | is-empty) { ^git branch -D ...$rest } else { ^git branch -D $branch ...$rest }
}

export alias gpr = ^git pull --rebase

export def grst [] {
    git reset --hard
    git clean -fd
}

export def gpsh [
    --message(-m): string = "quick update"
] {
    git add .
    git commit -m $message
    git push
}

# ---------------------------------------------------------------------------- #

def display_entry [e type] {
    let state = $STATES | get ($e | get $type)
    let state_str = $state.display | paint with $state.style
    let file_str = $e.name | path highlight -l
    { state: $state_str, name: $file_str }
}

alias up-to-date = echo ('up to date' | paint green)
alias ahead = echo ('ahead' | paint green)
alias behind = echo ('behind' | paint yellow)

def n_commits [n] {
    if $n == 1 {
        $"('1' | paint purple) commit"
    } else {
        $"($n | paint purple) commits"
    }
}

def fetch [] {
    print ("Fetching updates..." | paint yellow)
    git fetch
    $env.LAST_FETCH = {dir: $env.PWD, time: (date now)}
}

export def `git stat` [] {
    let gstat = gstat
    if $gstat.repo_name == no_repository {
        error make -u {msg: "Not a git repository"}
    }
    # if $gstat.remote != '' { fetch; $gstat = gstat }
    print $"On branch ($gstat.branch | paint cyan)"

    if $gstat.remote != '' {
        let remote = 'remote ' + ($gstat.remote | paint blue)
        match $gstat {
            {behind: 0, ahead: 0} => { print $"  which is (up-to-date) with ($remote)." }
            {behind: $b, ahead: 0} => { print $"  which is (behind) ($remote) by (n_commits $b)." }
            {behind: 0, ahead: $a} => { print $"  which is (ahead) of ($remote) by (n_commits $a)." }
            {behind: $b, ahead: $a} => { print $"  which is (ahead) of ($remote) by (n_commits $a) and (behind) by (n_commits $b)." }
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
