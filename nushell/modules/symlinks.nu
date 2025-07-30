# ---------------------------------------------------------------------------- #
#                                 symlinks.nu                                  #
# ---------------------------------------------------------------------------- #

# Create a symboic link to a file or directory
export def link [
    path: string        # Path to the target file or directory
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
    [
        {
            link: '~/Projects/dotfiles/neovim'
            target: '~/AppData/Local/nvim'
            type: 'dir'
        }
        {
            link: '~/Projects/dotfiles/nushell/config.nu'
            target: '~/AppData/Roaming/nushell/config.nu'
            type: 'file'
        }
        {
            link: '~/Projects/dotfiles/nushell/aliases.nu'
            target: '~/AppData/Roaming/nushell/aliases.nu'
            type: 'file'
        }
        {
            link: '~/Projects/dotfiles/nushell/zoxide.nu'
            target: '~/AppData/Roaming/nushell/zoxide.nu'
            type: 'file'
        }
    ] | each {|e|
        print $e
    }

}

