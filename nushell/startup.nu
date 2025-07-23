# ---------------------------------------------------------------------------- #
#                                  startup.nu                                  #
# ---------------------------------------------------------------------------- #

use modules/color.nu 'ansi apply'
use modules/ansi.nu ['cursor off' 'cursor on']
use modules/version.nu 'version full-check'
use modules/procedure.nu ['procedure run' 'procedure new-task']
use modules/print-utils.nu 'countdown'
use modules/shadows.nu ls-builtin

cursor off

procedure run "Startup" {

    # ---------------------------------- nushell --------------------------------- #

    procedure new-task -c "Setting up Nushell" {
        procedure new-task "Verifying commands file exists" {
            if not ('~/.sys-commands.nu' | path exists) {
                procedure new-task "Creating commands file" {
                    touch $env.SYS_COMMANDS_FILE
                }
            }
        }
        procedure new-task "Verifying variables file exists" {
            if not ('~/.nu-vars.toml' | path exists) {
                procedure new-task "Creating variables file" {
                    touch $env.VARS_FILE
                }
            }
        }
        procedure new-task -c "Checking nushell version" {
            if not (version full-check).current {
                error make -u { msg: "Nushell out of date" }
            }
        }
        procedure new-task -c "Updating nushell scripts" -e "Commit or stash unstaged changes" {
            let path = ['~' 'Projects' nushell-scripts] | path join
            cd $path
            git pull -r
            cd -
        }
        # procedure new-task "Updating module imports" {
        #     const imports_file = '~/Projects/nushell-scripts/imports.nu' | path expand
        #     procedure new-task "Creating new mod file" {
        #         if ($imports_file | path exists) {
        #             rm $imports_file
        #         } else {
        #             touch $imports_file
        #         }
        #     }
        #     procedure new-task "Writing module imports to mod file" {
        #         let modules = (ls-builtin ~/Projects/nushell-scripts/modules/ | get name | path basename)
        #         for module in $modules {
        #             $"use modules/($module) *\n" | save -a $imports_file
        #         }
        #     }
        # }
    }

    # ------------------------------ cargo projects ------------------------------ #

    procedure new-task -c "Updating cargo projects" {
        let cargo_repos = [
            bar
            rusty-gpt
            size-converter
            byte-converter
        ]
        for repo in $cargo_repos {
            procedure new-task -c $"Updating ($repo | ansi apply blue)" {
                let path = ['~' 'Projects' $repo] | path join
                procedure new-task "Verifying project directory exists" {
                    if not ($path | path exists) {
                        procedure new-task "Cloning project repository" {
                            let projects_dir = ['~' 'Projects'] | path join
                            cd $projects_dir
                            git clone $"https://github.com/brendon-felix/($repo).git"
                        }
                    }
                }
                cd $path
                procedure new-task "Pulling changes from remote" -e "Ensure repo exists and changes are committed" {
                    git pull -r
                }
                procedure new-task "Building project" {
                    cargo build --release
                }
                cd -
            }
        }
    }

    # ------------------------------ nushell plugins ------------------------------ #

    procedure new-task -c "Updating nushell plugins" {
        let nushell_plugins = [
            nu_plugin_highlight
            nu_plugin_semver
        ]
        for package in $nushell_plugins {
            procedure new-task -c $"Updating ($package | ansi apply blue)" {
                cargo install $package
            }
            procedure new-task -c $"Registering ($package | ansi apply blue)" {
                let bin = ls ~/.cargo/bin | get name | where {|f| $f | str contains $package} | first
                plugin add $bin
            }
        }
    }

    # ------------------------------ cargo packages ------------------------------ #

    procedure new-task -c "Updating cargo packages" {
        let cargo_packages = [
            coreutils
            du-dust
            ripgrep
            fd-find
            # asciibar
            bat
            # zoxide
        ]
        for package in $cargo_packages {
            procedure new-task -c $"Updating ($package | ansi apply blue)" {
                cargo install $package
            }
        }
    }
    procedure new-task -c "Initializing zoxide script" {
        zoxide init nushell | save ~/.zoxide.nu
    }
}

cursor on

print "Exiting startup script..."
countdown 30sec

# print "Press Enter to exit..."
# input

exit
