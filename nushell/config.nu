# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

use std null-device

source aliases.nu
source zoxide.nu
source ~/.sys-commands.nu
use modules/jobs.nu *

use banner.nu [info 'print banner']

const gstat_values = [
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
    {value: conflicts, display: $"(ansi red_bold)C(ansi reset)"}
    {value: stashes, display: $"(ansi magenta)S:(ansi reset)"}
    {value: ahead, display: $"(ansi green)↑:(ansi reset)"}
    {value: behind, display: $"(ansi red)↓:(ansi reset)"}
]

# ------------------------------ env variables ------------------------------- #

$env.EDITOR = 'nvim'

# $env.PROMPT_COMMAND = {||
#     let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
#         null => $env.PWD
#         '' => '~'
#         $relative_pwd => ([~ $relative_pwd] | path join)
#     }
#     let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
#     $"($path_color)($dir)(ansi reset)"
#     # $"($dir)" | ansi gradient -a '0x56B6C2' -b '0x98C379'
# }

# $env.PROMPT_COMMAND_RIGHT = { || (info icons -c default | grid | lines | first) }
# $env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
$env.PROMPT_COMMAND_RIGHT = {
    mut info = info icons -c default
    if $env.FIRST_PROMPT { $env.FIRST_PROMPT = false } else { $info = $info | last 1 }
    try {
        let git_status = job recv --all --timeout 50ms | last
        if $git_status.repo_name != no_repository {
            let values = $gstat_values
            let values = $values | upsert num {|row| $git_status | get $row.value}
            let num_changes = $values | get num | math sum
            let branch_color = if $num_changes > 0 { 'yellow_bold' } else { 'green_bold' }
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

$env.PROMPT_INDICATOR_VI_NORMAL = { ||
    let color = if $env.MODULES_LOADED { 'light_purple' } else { 'cyan' }
    $"(ansi $color)>(ansi reset) "
}
$env.PROMPT_INDICATOR_VI_INSERT = { ||
    let color = if $env.MODULES_LOADED { 'light_purple' } else { 'cyan' }
    $"(ansi $color)>(ansi reset) "
}
$env.PROMPT_MULTILINE_INDICATOR = ''

mut paths = [
    ('~/Projects/bar/target/release/' | path expand)
    ('~/Projects/hey/target/release/' | path expand)
    ('~/Projects/spewcap/target/release/' | path expand)
    ('~/Projects/size-converter/target/release/' | path expand)
]
if $nu.os-info.name == 'macos' {
    $paths = $paths | append [
        ('/usr/local/bin')
        ('/opt/homebrew/bin/')
        ('~/Library/Python/3.9/bin/' | path expand)
        ('~/.cargo/bin/' | path expand)
    ]
}
let paths = $paths | where { |path| $path | path exists }
$env.Path = $env.Path | append $paths

# ----------------------------- custom variables ----------------------------- #

$env.BIOS_CONFIGS = try { open ~/.bios-configs.toml } catch { null }
$env.FIRST_PROMPT = true
$env.MODULES_LOADED = false
$env.VARS_FILE = ('~/.nu-vars.toml' | path expand)
$env.PROCEDURE_LEVEL = 0
$env.PROCEDURE_DEBUG = false
$env.USERNAME = ($nu.home-path | path basename)

# ---------------------------------- config ---------------------------------- #

$env.config.buffer_editor = $env.EDITOR
$env.config.edit_mode = 'vi'
# $env.config.history.isolation = true
$env.config.show_banner = false
# $env.config.show_banner = 'short'
$env.config.float_precision = 3
# $env.config.hooks.env_change = { HOMEPATH: [{|| print (info | grid) }] }
# $env.config.hooks.env_change = { HOMEPATH: [{|| use ~/Projects/dotfiles/nushell/modules *}] }

$env.config.hooks.pre_prompt = [
    { job spawn {gstat | job send 0 --tag 42 } }
]
$env.config.hooks.pre_execution = [
    { if $env.FIRST_PROMPT { $env.FIRST_PROMPT = false } }
]
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"
$env.config.plugins.highlight.theme = 'ansi'

# ----------------------------- custom commands ------------------------------ #

def show [file: path] {
    open -r $file | highlight
}

# load API key environment variables
if ('~/Arrowhead/Files/keys.toml' | path exists) {
    load-env (open ~/Arrowhead/Files/keys.toml | items {|k, v|
        {($k | str upcase): $v}
    } | into record)
}

export def lg [
    --all (-a),         # Show hidden files
    ...pattern: glob,   # The glob pattern to use.
] {
    let pattern = if ($pattern | is-empty) { [ '.' ] } else { $pattern }
    ls -s --all=$all ...$pattern | grid -c
}

def `git stat` [] {
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


print banner header
if $nu.os-info == macos {
    overlay use ~/Projects/dotfiles/nushell/modules
}
