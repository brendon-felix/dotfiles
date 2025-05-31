# ---------------------------------------------------------------------------- #
#                                applications.nu                               #
# ---------------------------------------------------------------------------- #

def start_app [app_name] {
    let shortcut_filename = $"($app_name).lnk"
    let possible_paths = [
        ([$env.APPDATA, `Microsoft\Windows\Start Menu\Programs`, $shortcut_filename] | path join),
        ([$env.APPDATA, `Microsoft\Windows\Start Menu\Programs`, $app_name, $shortcut_filename] | path join),
        ([$env.ProgramData, `Microsoft\Windows\Start Menu\Programs`, $shortcut_filename] | path join),
        ([$env.ProgramData, `Microsoft\Windows\Start Menu\Programs`, $app_name, $shortcut_filename] | path join)
    ]
    mut result: any = null
    for $path in $possible_paths {
        if ($path | path exists) {
            $result = $path
        }
    }
    if $result == null {
        error make {
            msg: $"Shortcut for ($app_name) not found in any of the expected paths.",
            label: {
                text: "Application not found"
                span: (metadata $app_name).span
            }
        }
    } else {
        start $result
    }
} 

alias ticktick = start_app "TickTick"
alias todo = start_app "TickTick"
alias obsidian = start_app "Obsidian"
alias notes = start_app "Obsidian"
alias zen = start_app "Zen"
alias arc = start_app "Arc"
alias rw = start_app "Rw"
alias email = start_app "Spark Desktop"
alias excel = start_app "Excel"
alias chrome = start_app "Google Chrome"
alias onedrive = start_app "OneDrive"
alias word = start_app "Word"