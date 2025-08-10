# ---------------------------------------------------------------------------- #
#                                 symlinks.nu                                  #
# ---------------------------------------------------------------------------- #

use procedure.nu *
use path.nu *

# This is an update

export def link [
    path: string        # Path to use for the symlink
    --dir(-d)           # Create a directory symlink
]: string -> nothing {
    let target = $in | path expand
    let link = $path | path expand
    match $dir {
        true => (run-external 'mklink' '/D' $link $target)
        false => (run-external 'mklink' $link $target)
    }
}

export def `link dotfiles` [] {
    let links = [
        {
            link: '~/Projects/dotfiles/neovim'
            target: '~/AppData/Local/nvim'
            dir: true
        }
        {
            link: '~/Projects/dotfiles/nushell/config.nu'
            target: '~/AppData/Roaming/nushell/config.nu'
            dir: false
        }
        {
            link: '~/Projects/dotfiles/nushell/aliases.nu'
            target: '~/AppData/Roaming/nushell/aliases.nu'
            dir: false
        }
        {
            link: '~/Projects/dotfiles/nushell/zoxide.nu'
            target: '~/AppData/Roaming/nushell/zoxide.nu'
            dir: false
        }
    ]
    procedure run "Creating symlinks for dotfiles" {
        for link in $links {
            procedure new-task -c $"Linking ($link.link | path slice (-2)..(-1)) to ($link.target | path slice (-2)..(-1))" {
                $link.target | link $link.link --dir=$link.dir
            }
        }
    }
}

