# ---------------------------------------------------------------------------- #
#                                  startup.nu                                  #
# ---------------------------------------------------------------------------- #

use std null-device
use modules/print-utils.nu bar
use modules/color.nu 'color apply'
use modules/core.nu ['suppress all' 'var save' 'var load']
use modules/ansi.nu ['cursor off' 'cursor on' 'erase right']
use modules/version.nu 'version full-check'

cursor off

cd ~/Projects/nushell-scripts
try {
    print -n "Updating nushell scripts...  "
    { git pull --rebase } | suppress all
    touch ~/Projects/nushell-scripts/commands.nu
    print ("Done" | color apply green)
} catch {|err|
    print ("Failed" | color apply yellow)
}
cd ~

let cargo_packages = [
    bat
    ripgrep
    asciibar
    du-dust
    nu_plugin_highlight
    nu_plugin_semver
]
try {
    $cargo_packages | enumerate | each {|e|
        let new_bar = (bar (($e.index) / ($cargo_packages | length)))
        print -n $"Installing latest cargo packages...  ($new_bar) \(($e.item)\)"
        erase right
        print -n "\r"
        { cargo -q install $e.item } | suppress all
    }
    # cargo install ripgrep asciibar du-dust nu_plugin_highlight nu_plugin_semver
    print ("Done" | color apply green)
} catch {|err|
    print ("Failed" | color apply yellow)
}

version full-check

# try {
#     print "Installing latest Nushell version..."
#     winget install --silent Nushell.Nushell
#     print $"Installing latest cargo packages...    (ansi green)Done(ansi reset)"
# } catch {|err|
#     print $"Installing latest cargo packages...  (ansi yellow)Failed(ansi reset)"
# }

cursor on
