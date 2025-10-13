
use procedure.nu *

export def `re-export all` [
    directory: path = '.'
    --dry-run
] {
    let pattern = $directory | path join '*.nu' | into glob
    let module_names = ls $pattern | where {|m| ($m.name | path basename) != 'mod.nu'} | get name
    let re_exports = $module_names | each {|m|
        $"export use ($m | path basename) *"
    }
    if $dry_run {
        print ($re_exports | str join "\n" | highlight nu)
    } else {
        let mod_file = $directory | path join 'mod.nu'
        $re_exports | save -f $mod_file
    }
}

def "nu-complete command-list-type" [] {
    ['built-in', 'external', 'custom', 'alias', 'plugin']
}
export def command-list [
    type?: string@"nu-complete command-list-type"
] {
    let commands = if $type == null {
        help commands
    } else {
        help commands | where command_type == $type
    }
    $commands | select name description
}

# const LS_COLORS_PATH = $nu.data-dir | path join '.ls-colors'
# def `generate-ls` [] {
#     procedure new-task "Generating LS_COLORS with vivid" {
#         if (which vivid | is-empty) {
#             procedure print "Cannot generate LS_COLORS: vivid not found" -c red
#             error make -u {msg: "vivid not found"}
#         }
#         procedure new-task "Generating..." {
#             let ls_colors = vivid generate ($nu.data-dir | path join 'ls-colors.yaml')
#         }
#         procedure new-task "Saving to .ls-colors..." {
#             $ls_colors | save -f $LS_COLORS_PATH
#         }
#     }
# }
# export def `generate ls-colors` [
#     --force(-f)
#     --quiet(-q)
# ] {
#     procedure run "LS_COLORS generation" {
#         if ($LS_COLORS_PATH | path exists) {
#             procedure new-task "Check existing .ls-colors file" {
#                 if $force {
#                     procedure print "Found existing .ls-colors file" -c yellow
#                     generate-ls
#                 } else {
#                     procedure print "Found existing .ls-colors file" -c green
#                 }
#             }
#         } else {
#             procedure new-task "Check existing .ls-colors file" {
#                 procedure print "No .ls-colors file found" -c yellow
#             }
#             generate-ls
#         }
#     }
#     # if not ('.lscolors' | path exists) or $force {
#     #     try { rm .ls-colors; print "removed .ls-colors" } catch { print ".ls-colors not preset" }
#     # } else if not $quiet {
#     #     print ".ls-colors already exists, use --force to overwrite"
#     #     return
#     # }
# }
