# ---------------------------------------------------------------------------- #
#                                   config.nu                                  #
# ---------------------------------------------------------------------------- #

source aliases.nu
source zoxide.nu

use banner.nu info

# ------------------------------ env variables ------------------------------- #

# $env.VARS_FILE = ('~/.nu-vars.toml' | path expand)
$env.PROCEDURE_LEVEL = 0
$env.PROCEDURE_DEBUG = false
# $env.BIOS_PROJECTS = open ('~/Projects/nushell-scripts/bios/projects.json' | path expand)
# $env.CURR_PROJECT = $env.BIOS_PROJECTS | find -n 'Springs' | first
$env.EDITOR = 'nvim'
# $env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }
# $env.PROMPT_COMMAND_RIGHT = { || (info icons -c default | prepend $"(ansi light_purple)(date now | format date "%r")(ansi reset)" | grid | lines | first) }
$env.PROMPT_COMMAND_RIGHT = { || (info icons -c default | grid | lines | first) }
# $env.PROMPT_COMMAND_RIGHT = { || }

$env.MODULES_LOADED = false

$env.PROMPT_INDICATOR_VI_NORMAL = { ||
    let color = if $env.MODULES_LOADED { 'light_purple' } else { 'cyan' }
    $"(ansi $color)>(ansi reset) "
}
$env.PROMPT_INDICATOR_VI_INSERT = { ||
    let color = if $env.MODULES_LOADED { 'light_purple' } else { 'cyan' }
    $"(ansi $color)>(ansi reset) "
}
$env.PROMPT_MULTILINE_INDICATOR = ''

$env.Path = $env.Path | append [
    ('~/Projects/bar/target/release/' | path expand)
    ('~/Projects/rusty-gpt/target/release/' | path expand)
    ('~/Projects/spewcap2/target/release/' | path expand)
    ('~/Projects/size-converter/target/release/' | path expand)
    ('~/Projects/mix/target/release/' | path expand)
    ('~/Projects/qalculate/' | path expand)
]

# -------------------------------- env config -------------------------------- #

$env.config.buffer_editor = $env.EDITOR
$env.config.edit_mode = 'vi'
$env.config.history.isolation = true
$env.config.show_banner = false
# $env.config.show_banner = 'short'
$env.config.float_precision = 3
# $env.config.hooks.env_change = { HOMEPATH: [{|| print (info | grid) }] }
# $env.config.hooks.env_change = { HOMEPATH: [{|| use ~/Projects/dotfiles/nushell/modules *}] }
$env.config.cursor_shape.vi_insert = "blink_line"
$env.config.cursor_shape.vi_normal = "blink_block"
$env.config.plugins.highlight.theme = 'ansi'


def show [file] {
    open -r $file | highlight
}

# load API key environment variables
if ('~/Arrowhead/Files/keys.toml' | path exists) {
    load-env (open ~/Arrowhead/Files/keys.toml | items {|k, v|
        {($k | str upcase): $v}
    } | into record)
}


alias ls-builtin = ls

# List the filenames, sizes, and modification times of items in a directory.
export def ls [
    --all (-a),         # Show hidden files
    --full-paths (-f),  # display paths as absolute paths
    ...pattern: glob,   # The glob pattern to use.
] {
    let pattern = if ($pattern | is-empty) { [ '.' ] } else { $pattern }
    (ls-builtin
        --all=$all
        --short-names=(not $full_paths)
        --full-paths=$full_paths
        ...$pattern
    ) | grid -c
}

# List the contents of a directory in a tree-like format.
def lst [--level(-L): int = 2] {
    tree.exe -C -L $level --dirsfirst --noreport -H
}

# if $nu.is-interactive {
#     alias ls-builtin = ls
#     alias ls = `ls | grid --color --icons`
# }

