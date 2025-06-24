# ---------------------------------------------------------------------------- #
#                                  startup.nu                                  #
# ---------------------------------------------------------------------------- #

# use std null-device
use modules/color.nu 'color apply'
use modules/ansi.nu ['cursor off' 'cursor on']
use modules/version.nu 'version full-check'
use modules/procedure.nu *

cursor off

procedure run "Startup" {
    # ---------------------------------- nushell --------------------------------- #
    procedure new-task "Setting up Nushell" {
        procedure new-task "Verifying variables file exists" {
            if not ($env.VARS_FILE | path exists) {
                procedure new_subtask "Creating variables file" {
                    touch $env.VARS_FILE
                }
            }
        }
        procedure new-task -c "Checking nushell version" {
            if not (version full-check).current {
                error make -u { msg: "Nushell out of date" }
            }
        }
        procedure new-task -c "Updating nushell scripts" {
            let path = ['~' 'Projects' nushell-scripts] | path join
            cd $path
            git pull -r
            cd -
        }
    }
    # ------------------------------ cargo projects ------------------------------ #
    procedure new-task "Updating cargo projects" {
        let cargo_repos = [
            bar
            rusty-gpt
            size-converter
            byte-converter
        ]
        for repo in $cargo_repos {
            procedure new-task -c $"Updating ($repo | color apply blue)" {
                let path = ['~' 'Projects' $repo] | path join
                procedure new-task "Verifying project directory exists" {
                    if not ($path | path exists) {
                        procedure new-subtask "Cloning project repository" {
                            let projects_dir = ['~' 'Projects'] | path join
                            cd $projects_dir
                            git clone $"https://github.com/brendon-felix/($repo).git"
                        }
                    }
                }
                cd $path
                procedure new-task "Pulling changes from remote" -e "Commit or stash unstaged changes" {
                    git pull -r
                }
                procedure new-task "Building project" {
                    cargo build --release
                }
                cd -
            }
        }
    }
    # ------------------------------ cargo packages ------------------------------ #
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
            procedure new-task -c $"Updating ($package | color apply blue)" {
                cargo install $package
            }
        }
    }
}

cursor on
