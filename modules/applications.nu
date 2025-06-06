# ---------------------------------------------------------------------------- #
#                                applications.nu                               #
# ---------------------------------------------------------------------------- #

export def start_app [app_name] {
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

# export alias ticktick = start_app "TickTick"
# export alias todo = start_app "TickTick"
# export alias obsidian = start_app "Obsidian"
# export alias notes = start_app "Obsidian"
# export alias zen = start_app "Zen"
# export alias arc = start_app "Arc"
# export alias rw = start_app "Rw"
# export alias email = start_app "Spark Desktop"
# export alias excel = start_app "Excel"
# export alias chrome = start_app "Google Chrome"
# export alias onedrive = start_app "OneDrive"
# export alias word = start_app "Word"
