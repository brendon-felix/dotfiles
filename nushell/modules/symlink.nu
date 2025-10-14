# ---------------------------------------------------------------------------- #
#                                  symlink.nu                                  #
# ---------------------------------------------------------------------------- #

use procedure.nu *
use paint.nu main

export def main [
    source: path
    link: path
    --force(-f)
] {
    match ($link | path expand) {
        $l if ($l | path exists) and $force => {
            rm -r $l
        }
        $l if ($l | path exists) => {
            error make {
                msg: $"link path already exists: ($l | ls-colorize)"
                label: {
                    text: "use --force(-f) to overwrite"
                    span: (metadata $link).span
                }
            }
        }
        _ => {}
    }
    match $nu.os-info.name {
        windows => {
            if ($source | path type) == dir {
                procedure new-task $"Creating directory symlink ($link | paint red) -> ($source | paint cyan)" {
                    ^mklink /D ($link | path expand) ($source | path expand)
                }
            } else {
                procedure new-task $"Creating file symlink ($link | paint red) -> ($source | paint cyan)" {
                    ^mklink ($link | path expand) ($source | path expand)
                }
            }
            return
        }
        _ => {
            ^ln -s ($source | path expand) ($link | path expand)
        }
    }
}

export def `dotfiles link-all` [] {
    let dotfiles = match $nu.os-info.name {
        windows => [
            # [source link];
            # [alacritty]
            # [bat]
            # [ghostty]
            # [gitui]
            # [helix]
            # [neovim]
            # [nushell]
            # [windows-terminal]
            # [zed]
        ]
        macos => [
            [source    link];
            [alacritty ~/.config/alacritty]
            [bat       ~/.config/bat]
            [ghostty   ~/.config/ghostty]
            [gitui     ~/.config/gitui]
            [helix     ~/.config/helix]
            [neovim    ~/.config/nvim]
            [nushell   '~/Library/Application Support/nushell']
            [zed       ~/.config/zed]
        ]
        linux => [
            # [source link];
            # [alacritty]
            # [bat]
            # [ghostty]
            # [gitui]
            # [helix]
            # [neovim]
            # [nushell]
            # [windows-terminal]
            # [zed]
        ]
    }

    procedure run "Linking dotfiles" {
        procedure new-task "Linking dotfiles" {
        for dotfile in $dotfiles {
            let link = $dotfile.link
            let source = '~/Projects/dotfiles' | path join $dotfile.source
            procedure new-task -c $"Linking ($source | path basename | paint cyan)" {
                if ($link | path exists) {
                    if ($link | path type) != symlink {
                        match (input -n 1 $"Path ($link | ls-colorize) already exists. Overwrite? [y/N]: ") {
                            'y' | 'Y' => {
                                procedure new-task $"Removing existing ($link | path basename)" {
                                    rm -r ($link | path expand)
                                }
                                procedure new-task $"Creating symlink ($link | paint red) -> ($source | paint cyan)" {
                                    main $source $link
                                }
                            }
                            'n' | 'N' | '' => {
                                procedure print $"Skipping ($source | path basename)"
                            }
                            _ => {
                                procedure print $"Invalid input. Skipping ($source| path basename)"
                            }
                        }
                    } else {
                        procedure print $"Symlink already exists"
                    }
                } else {
                    procedure new-task $"Creating symlink ($link | paint red) -> ($source | paint cyan)" {
                        main $source $link
                    }
                }
            }
        }
        }
    }
}
