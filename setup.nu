
# Windows
if not (which git | is-empty) {
    cd  ~/Projects
    git clone https://github.com/brendon-felix/nushell-scripts.git
    touch ~/.nu-vars.toml
    touch ~/.sys-commands.nu
    "source ~/Projects/nushell-scripts/config.nu\n" | save -f $nu.config-path
} else {
    print "Installing git..."
    try {
        winget install --id Git.Git -e --source winget
        print "git installed successfully."
    } catch {
        error make -u { msg: "Could not install winget" }
    }
}

if not ([$env.LOCALAPPDATA 'nvim'] | path join | path exists) {
    cd $env.LOCALAPPDATA
    git clone https://github.com/brendon-felix/nvim-config.git nvim
}

if not (which z | is-empty) {
    print "zoxide is already installed."
} else {
    print "Installing zoxide..."
    try {
        winget install --id=ajeetdsouza.zoxide  -e
        print "zoxide installed successfully."
    } catch {
        error make -u { msg: "Could not install zoxide" }
    }
}

if not (which starship | is-empty) {
    print "starship is already installed."
} else {
    print "Installing starship..."
    try {
        winget install --id starship.starship -e
        print "starship installed successfully."
    } catch {
        error make -u { msg: "Could not install starship" }
    }
}

if not (which nu | is-empty) {
    print "nushell is already installed."
} else {
    print "Installing nushell..."
    try {
        winget install --id=Nushell.Nushell -e
        print "nushell installed successfully."
    } catch {
        error make -u { msg: "Could not install nushell" }
    }
}

if not (which nvim | is-empty) {
    print "neovim is already installed."
} else {
    print "Installing neovim..."
    try {
        winget install neovim
        print "neovim installed successfully."
 
    } catch {
        error make -u { msg: "Could not install neovim" }
    }
}

if not (which fd | is-empty) {
    print "fd is already installed."
} else {
    print "Installing fd..."
    try {
        winget install sharkdp.fd
        print "fd installed successfully."
    } catch {
        error make -u { msg: "Could not install fd" }
    }
}

if not (which fzf | is-empty) {
    print "fzf is already installed."
} else {
    print "Installing fzf..."
    try {
        winget install fzf
        print "fzf installed successfully."
    } catch {
        error make -u { msg: "Could not install fzf" }
    }
}

if not (which gitui | is-empty) {
    print "gitui is already installed."
} else {
    print "Installing gitui..."
    try {
        winget install gitui
        print "gitui installed successfully."
    } catch {
        error make -u { msg: "Could not install gitui" }
    }
}
