# ---------------------------------------------------------------------------- #
#                                  startup.nu                                  #
# ---------------------------------------------------------------------------- #

use std null-device
# use modules/print-utils.nu bar
use modules/color.nu 'color apply'
use modules/core.nu ['suppress all' 'suppress stderr' 'var save' 'var load']
use modules/ansi.nu ['cursor off' 'cursor on' 'erase right']
use modules/version.nu 'version full-check'

cursor off

# ---------------------------------- nushell --------------------------------- #

print -n (("Checking " | color apply blue) + ("nushell" | color apply green) + " version...  ")
match (version full-check).current {
    true => ("Current" | color apply green)
    false => ("Outdated" | color apply yellow)
} | print

print -n (("Updating " | color apply blue) + ("nushell scripts" | color apply light_purple) + "...  ")
cd ~/Projects/nushell-scripts
try {
    {git pull -r} | suppress all
    print ("Done" | color apply green)
} catch {
    print ("Failed" | color apply yellow)
}
cd -

# ------------------------------------ git ----------------------------------- #

let cargo_repos = [
    nushell-scripts
    bar
    rusty-gpt
    size-converter
    byte-converter
]
print ("Updating project repos..." | color apply light_purple)
$cargo_repos | enumerate | each {|e|
    try {
        print $"  ($e.item | color apply blue)... "
        cd (['~' 'Projects' $e.item] | path join)
        {git pull -r} | suppress all
        print $"  Building ($e.item)... "
        {cargo build --release} | suppress all
        print ("    Done" | color apply green)
    } catch {
        print ("    Failed" | color apply yellow)
    }
}
cd -

# ----------------------------------- cargo ---------------------------------- #

let cargo_packages = [
    nu_plugin_highlight
    nu_plugin_semver
    du-dust
    ripgrep
    # asciibar
    bat
]
let message = "Updating cargo packages...  "
$cargo_packages | enumerate | each {|e|
    let new_bar = (bar (($e.index) / ($cargo_packages | length)))
    print -n $"($message)($new_bar) \(($e.item)\)"
    erase right
    print -n "\r"
    try {
        { cargo -q install $e.item } | suppress all
        # cargo install ripgrep asciibar du-dust nu_plugin_highlight nu_plugin_semver
    } catch {|err|
        print ($message + ("Failed" | fill -w 12 | color apply yellow))
    }
}
print ($message + ("Done" | fill -w 12 | color apply green))







cursor on
