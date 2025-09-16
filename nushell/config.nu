# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

use std null-device

source aliases.nu
source zoxide.nu

use banner.nu info

# ------------------------------ env variables ------------------------------- #

$env.EDITOR = 'nvim'

# $env.PROMPT_COMMAND = {||
#     let is_git_repo = match (^git rev-parse --is-inside-work-tree | complete | get stdout | str trim) {
#         'true' => true
#         _ => false
#     }
#     if $is_git_repo {
#         let branch = (git symbolic-ref --short HEAD | str trim)
#         let status = (git status --porcelain | length)
#         let branch_color = if $status > 0 { 'red_bold' } else { 'green_bold' }
#         let status_symbol = if $status > 0 { '*' } else { '' }
#         let git_segment = $"(ansi $branch_color) ($branch)($status_symbol)(ansi reset) "
#         $git_segment
#     } else {
#         ''
#     }
#     # let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
#     #     null => $env.PWD
#     #     '' => '~'
#     #     $relative_pwd => ([~ $relative_pwd] | path join)
#     # }
#     #
#     # let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
#     # let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
#     # let path_segment = $"($path_color)($dir)(ansi reset)"
#     #
#     # $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
# }
$env.PROMPT_COMMAND_RIGHT = { || (info icons -c default | grid | lines | first) }
# $env.PROMPT_COMMAND_RIGHT = { || }
# $env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
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
    ('~/Projects/zed/target/release/' | path expand)
    # ('~/Projects/mix/target/release/' | path expand)
    # ('~/Projects/qalculate/' | path expand)
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

$env.MODULES_LOADED = false
# $env.VARS_FILE = ('~/.nu-vars.toml' | path expand)
$env.PROCEDURE_LEVEL = 0
$env.PROCEDURE_DEBUG = false
# $env.BIOS_PROJECTS = open ('~/Projects/nushell-scripts/bios/projects.json' | path expand)
# $env.CURR_PROJECT = $env.BIOS_PROJECTS | find -n 'Springs' | first

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
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"
$env.config.plugins.highlight.theme = 'ansi'

# ----------------------------- custom commands ------------------------------ #

def show [file: path] {
    open -r $file | highlight
}

def --env `vault store` [path?: glob] {
    # let vault_path = try {
    #     (sys disks | where device == Vault | first | get mount)
    # } catch {
    #     error make -u { msg: "Vault not available" }
    # }
    # let path = if $relpath != null {
    #     [$vault_path $relpath] | path join
    # } else {
    #     $vault_path
    # }
    # cd $path
}

def `vault load` [] {
    # let vault_path = try {
    #     (sys disks | where device == Vault | first | get mount)
    # } catch {
    #     error make -u { msg: "Vault not available" }
    # }
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

print banner
