# ---------------------------------------------------------------------------- #
#                                 symlinks.nu                                  #
# ---------------------------------------------------------------------------- #

use procedure.nu *
use path.nu *

export def `path type` []: string -> string {
    let path = $in | path expand -n
    if ($path | path exists) {
        let parent = $path | path join '..' | path expand -n
        ls-builtin $parent | where name == $path | first | get type
    } else {
        error make {
            msg: "invalid path"
            label: {
                text: "path does not exist"
                span: (metadata $path).span
            }
        }
    }
}

export def link [
    target: string      # Path to use for the symlink
    --dir(-d)           # Create a directory symlink
]: string -> nothing {
    let link = $in | path expand -n
    let target = $target | path expand -n
    match ($target | path type) {
        'file' => (run-external 'mklink' $link $target)
        'dir' => (run-external 'mklink' '/D' $link $target)
        'symlink' => {
            error make {
                msg: "invalid link type"
                label: {
                    text: "symlink already exists"
                    span: (metadata $link).span
                }
            }
        }
        _ => {
            error make {
                msg: "invalid link type"
                label: {
                    text: "expected a file or directory"
                    span: (metadata $link).span
                }
            }
        }
    }
}

export def `link dotfiles` [] {
    let links = [
        {
            link: '~/AppData/Local/nvim'
            target: '~/Projects/dotfiles/neovim'
        }
        {
            link: '~/Appdata/Roaming/alacritty'
            target: '~/Projects/dotfiles/alacritty'
        }
        {
            link: '~/AppData/Roaming/nushell/config.nu'
            target: '~/Projects/dotfiles/nushell/config.nu'
        }
        {
            link: '~/AppData/Roaming/nushell/aliases.nu'
            target: '~/Projects/dotfiles/nushell/aliases.nu'
        }
        {
            link: '~/AppData/Roaming/nushell/zoxide.nu'
            target: '~/Projects/dotfiles/nushell/zoxide.nu'
        }
        {
            link: '~/AppData/Roaming/nushell/banner.nu'
            target: '~/Projects/dotfiles/nushell/banner.nu'
        }
        {
            link: (glob '~/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json' | first)
            target: '~/Projects/dotfiles/windows-terminal/settings.json'
        }
    ]

    procedure run -d "Creating symlinks for dotfiles" {
        for link in $links {
            procedure new-task -c $"Linking ($link.target | path basename)" {
                if ($link.link | path exists) {
                    let expanded_link = $link.link | path expand -n
                    match ($link.link | path type) {
                        'dir' => {
                            procedure print $"(ansi yellow)Directory already exists:(ansi reset) ($link.link | path slice (-2)..(-1))"
                            let input = procedure get-input -n 1 -d 'n' $"Do you want to overwrite it? \(y/n\): "
                            match ($input | str trim | str downcase) {
                                'y' | 'yes' => {
                                    procedure new-task "Removing existing directory..." {
                                        rm -r $expanded_link
                                    }
                                    procedure new-task "Linking..." {
                                        $link.link | link $link.target
                                    }
                                }
                                _ => {
                                    error make -u { msg: "Skipping" }
                                }
                            }
                        }
                        'file' => {
                            procedure print $"(ansi yellow)File already exists:(ansi reset) ($link.link | path slice (-2)..(-1))"
                            let input = procedure get-input -n 1 -d 'n' $"Do you want to overwrite it? \(y/n\): "
                            match ($input | str trim | str downcase) {
                                'y' | 'yes' => {
                                    procedure new-task "Removing existing file..." {
                                        rm  $link.link
                                    }
                                    procedure new-task "Linking..." {
                                        $link.link | link $link.target
                                    }
                                }
                                _ => {
                                    error make -u { msg: "Skipping" }
                                }
                            }
                        }
                        'symlink' => {
                            procedure print $"(ansi green)Symlink already exists(ansi reset)"
                        }
                        _ => {
                            error make {
                                msg: "invalid link type"
                                label: {
                                    text: "expected a file, directory, or symlink"
                                    span: (metadata $link.link).span
                                }
                            }
                        }
                    }
                } else {
                    procedure new-task $"Linking ($link.link | path slice (-2)..(-1) | paint blue) to ($link.target | path slice (-2)..(-1) | paint cyan)" {
                        $link.link | link $link.target
                    }
                }
            }
        }
    }
}
