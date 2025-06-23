# ---------------------------------------------------------------------------- #
#                                  startup.nu                                  #
# ---------------------------------------------------------------------------- #

use std null-device
use modules/color.nu 'color apply'
use modules/ansi.nu ['cursor off' 'cursor on' 'erase right']
use modules/version.nu 'version full-check'
use modules/procedure.nu *

cursor off

# ---------------------------------- nushell --------------------------------- #

procedure new-task -r "Checking for variables file" {
    if ($env.VARS_FILE | path exists) {
        ("Exists" | color apply green)
    } else {
        procedure new_subtask "Creating variables file" {
            touch $env.VARS_FILE
            "Done" | color apply green
        }
    }
}

procedure new-task -r "Checking nushell version" {
    match (version full-check).current {
        true => ("Current" | color apply green)
        false => ("Outdated" | color apply yellow)
    }
}

procedure new-task "Updating nushell scripts" {
    cd ~/Projects/nushell-scripts
    git pull -r
    # try { git pull -r } catch {
    #     procedure message ("Commit or stash new changes" | color apply yellow)
    #     error make -u { msg: "Failed to update nushell scripts" }
    # }
    cd -
}

# ------------------------------------ git ----------------------------------- #

let cargo_repos = [
    bar
    rusty-gpt
    size-converter
    byte-converter
]
for repo in $cargo_repos {
    procedure new-task $"Updating ($repo | color apply blue)" {
        let path = ['~' 'Projects' $repo] | path join
        if ($path | path exists) { 
            procedure print $"Verified project directoy exists"
        } else {
            procedure new-subtask $"Cloning project repository" {
                cd (['~' 'Projects'] | path join)
                git clone $"https://github.com/brendon-felix/($repo).git"
            }
        }
        cd $path
        procedure new-subtask $"Pulling changes from remote" {
            git pull -r
        }
        procedure new-subtask $"Building project" {
            cargo build --release
        }
        cd -
    }
}

# ----------------------------------- cargo ---------------------------------- #

procedure new-task "Updating cargo packages" {
    let cargo_packages = [
        nu_plugin_highlight
        nu_plugin_semver
        du-dust
        ripgrep
        # asciibar
        bat
    ]
    for package in $cargo_packages {
        procedure new-subtask $"Updating ($package | color apply blue)" {
            cargo install $package
        }
    }
}


print ""

cursor on
