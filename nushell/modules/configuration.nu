# ---------------------------------------------------------------------------- #
#                               configuration.nu                               #
# ---------------------------------------------------------------------------- #

use common.nu show

const CONFIGS = [
    [  name                         path                                ];
    [ alacritty     ~/Projects/dotfiles/alacritty/alacritty.toml        ]
    [ bat           ~/Projects/dotfiles/bat/config                      ]
    [ ghostty       ~/Projects/dotfiles/ghostty/config                  ]
    [ gitui         ~/Projects/dotfiles/gitui/key_bindings.ron          ]
    [ helix         ~/Projects/dotfiles/helix/config.toml               ]
    [ hey           ~/Projects/dotfiles/hey/hey.toml                    ]
    [ neovim        ~/Projects/dotfiles/neovim/init.lu                  ]
    [ win-term      ~/Projects/dotfiles/windows-terminal/settings.json  ]
    [ yazi          ~/Projects/dotfiles/yazi/yazi.toml                  ]
    [ nu            ~/Projects/dotfiles/nushell/config.nu               ]
    [ private       ~/Vault/nushell/private.nu                          ]
    [ helpers       ~/Projects/dotfiles/nushell/helpers.nu              ]
    [ common        ~/Projects/dotfiles/nushell/modules/common.nu       ]
    [ aliases       ~/Projects/dotfiles/nushell/aliases.nu              ]
    [ banner        ~/Projects/dotfiles/nushell/modules/banner.nu       ]
    [ ssh           ~/.ssh/config                                       ]
]

def "nu-complete configs" [] {
    $CONFIGS | get name
}
export def config [
    name: string@"nu-complete configs"
    --editor(-e)
    --show(-s)
] {
    if $name not-in $CONFIGS.name {
        error make {
            msg: "invalid config name"
            label: {
                text: "name not recognized"
                span: (metadata $name).span
            }
        }
    }
    let path = $CONFIGS | where name == $name | get path | first | path expand
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
