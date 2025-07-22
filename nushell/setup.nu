
# Windows
if not (which git | is-empty) {
    git clone https://github.com/brendon-felix/dotfiles.git ~/Projects/dotfiles
    touch ~/.nu-vars.toml
    touch ~/.sys-commands.nu
    mklink $nu.config-path ('~/Projects/dotfiles/nushell/config.nu' | path expand)
    mklink /D ($nu.config-path | path join '..' 'modules' | path expand) ('~/Projects/dotfiles/nushell/modules' | path expand)
    mklink /D ($nu.config-path | path join '..' 'bios' | path expand) ('~/Projects/dotfiles/nushell/bios' | path expand)
    mklink /D ($nu.config-path | path join '..' 'completions' | path expand) ('~/Projects/dotfiles/nushell/completions' | path expand)
} else {
    print "Installing git..."
    try {
        winget install --id Git.Git -e --source winget
        print "git installed successfully."
    } catch {
        error make -u { msg: "Could not install winget" }
    }
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

if not (which fd | is-empty) {
    print "`fd` is already installed."
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
    print "`fzf` is already installed."
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

if not (which nvim | is-empty) {
    print "neovim is already installed."
} else {
    print "Installing neovim..."
    try {
        winget install neovim
        mklink /D ($env.LOCALAPPDATA | path join 'nvim') ('~/Projects/dotfiles/nvim' | path expand)
        print "neovim installed successfully."
 
    } catch {
        error make -u { msg: "Could not install neovim" }
    }
}
if not ([$env.LOCALAPPDATA 'nvim'] | path join | path exists) {
    cd $env.LOCALAPPDATA
    git clone https://github.com/brendon-felix/nvim-config.git nvim
}

