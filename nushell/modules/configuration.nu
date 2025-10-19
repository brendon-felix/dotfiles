# ---------------------------------------------------------------------------- #
#                               configuration.nu                               #
# ---------------------------------------------------------------------------- #

use common.nu show

def "nu-complete configs" [--paths] {
    let configs = [
        [  name                         path                                ];
        [ nushell       ~/Projects/dotfiles/nushell/config.nu               ]
        [ helpers       ~/Projects/dotfiles/nushell/helpers.nu              ]
        [ common        ~/Projects/dotfiles/nushell/modules/common.nu       ]
        [ aliases       ~/Projects/dotfiles/nushell/aliases.nu              ]
        [ banner        ~/Projects/dotfiles/nushell/modules/banner.nu       ]
        [ gitui         ~/Projects/dotfiles/gitui/key_bindings.ron          ]
        [ ghostty       ~/Projects/dotfiles/ghostty/config                  ]
        [ alacritty     ~/Projects/dotfiles/alacritty/alacritty.toml        ]
        [ neovim        ~/Projects/dotfiles/neovim/init.lu                  ]
        [ helix         ~/Projects/dotfiles/helix/config.toml               ]
        [ win-term      ~/Projects/dotfiles/windows-terminal/settings.json  ]
        [ yazi          ~/Projects/dotfiles/yazi/yazi.toml                  ]
    ]
    if $paths {
        $configs
    } else {
        $configs | get name
    }
}
export def config [
    name: string@"nu-complete configs"
    --editor(-e)
    --show(-s)
] {
    let configs = nu-complete configs --paths
    if not ($name in $configs.name) {
        error make {
            msg: "invalid config name"
            label: {
                text: "name not recognized"
                span: (metadata $name).span
            }
        }
    }
    let path = $configs | where name == $name | get path | first | path expand
    if $show {
        show $path
        return
    }
    if $editor {
        ^$env.EDITOR $path
    } else {
        ^$env.config.buffer_editor $path
    }
}
