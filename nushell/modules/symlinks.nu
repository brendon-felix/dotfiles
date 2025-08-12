# ---------------------------------------------------------------------------- #
#                                 symlinks.nu                                  #
# ---------------------------------------------------------------------------- #

use procedure.nu *
use path.nu *

export def link [
    target: string      # Path to use for the symlink
    --dir(-d)           # Create a directory symlink
]: string -> nothing {
    let link = $in | path expand
    let target = $target | path expand
    match $dir {
        false => (run-external 'mklink' $link $target)
        true => (run-external 'mklink' '/D' $link $target)
    }
}

export def `link dotfiles` [] {
    let links = [
        {
            link: '~/AppData/Local/nvim'
            target: '~/Projects/dotfiles/neovim'
            dir: true
        }
        {
            link: '~/AppData/Roaming/nushell/config.nu'
            target: '~/Projects/dotfiles/nushell/config.nu'
            dir: false
        }
        {
            link: '~/AppData/Roaming/nushell/aliases.nu'
            target: '~/Projects/dotfiles/nushell/aliases.nu'
            dir: false
        }
        {
            link: '~/AppData/Roaming/nushell/zoxide.nu'
            target: '~/Projects/dotfiles/nushell/zoxide.nu'
            dir: false
        }
        {
            link: '~/AppData/Roaming/nushell/banner.nu'
            target: '~/Projects/dotfiles/nushell/banner.nu'
            dir: false
        }
        {
            link: (glob '~/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json' | first)
            target: '~/Projects/dotfiles/windows-terminal/settings.json'
            dir: false
        }
{
            link: '~/Appdata/Roaming/alacritty/alacritty.toml'
            target: '~/Projects/dotfiles/alacritty/alacritty.toml'
        }
    ]
    procedure run "Creating symlinks for dotfiles" {
        for link in $links {
            procedure new-task -c $"Linking ($link.link | path slice (-2)..(-1) | ansi apply blue) to ($link.target | path slice (-2)..(-1) | ansi apply cyan)" {
                if ($link.link | path exists) {
                    procedure print $"(ansi yellow)Input path already exists:(ansi reset) ($link.link | path slice (-2)..(-1))"
                    let input = procedure get-input -n 1 -d 'n' $"Do you want to overwrite it? \(y/n\): "
                    match ($input | str trim | str downcase) {
                        'y' | 'yes' => {
                            match $link.dir {
                                true => {
                                    procedure new-task "Removing existing directory..." {
                                        rm -r $link.link
                                    }
                                }
                                false => {
                                    procedure new-task "Removing existing file..." {
                                        rm $link.link
                                    }
                                }
                            }
                        }
                        _ => {
                            error make -u { msg: "Skipping" }
                        }
                    }
                }
                procedure new-task "Linking..." {
                    $link.link | link $link.target --dir=$link.dir
                }
            }
        }
    }
}

