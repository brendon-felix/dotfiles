
# Windows
if not (which git | is-empty) {
    cd  ~/Projects
    git clone https://github.com/brendon-felix/nushell-scripts.git
    touch ~/.nu-vars.toml
    touch ~/.sys-commands.nu
    "source ~/Projects/nushell-scripts/config.nu\n" | save -f $nu.config-path
} else {
    print "Git is not installed. Attempting to install it with winget..."
    try {
        winget install --id Git.Git -e --source winget
    } catch {
        error make -u { msg: "Could not install winget" }
    }
}
