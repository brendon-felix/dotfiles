alias r = nu ./run.nu
alias du = dust
alias vim = nvim
# alias ln = coreutils ln
if not ((which ln) | is-empty) {
    alias ln = coreutils ln
}

alias untar = tar -xvf

alias py = python3

let shutdown_commands = if $nu.os-info.name == "windows" {
    {
        reboot: ['shutdown' '/r' '/t' '0']
        shutdown: ['shutdown' '/s' '/t' '0']
        hibernate: ['shutdown' '/h' '/t' '0']
        # sleep: 'rundll32.exe powrprof.dll,SetSuspendState 0,1,0'
    }
} else {
    {
        reboot: ['sudo' 'shutdown' '-r' 'now']
        shutdown: ['sudo' 'shutdown' '-h' 'now']
        hibernate: ['systemctl' 'hibernate']
        # sleep: 'systemctl suspend'
    }
}
alias reboot = run-external ...$shutdown_commands.reboot
alias shutdown = run-external ...$shutdown_commands.shutdown
alias hibernate = run-external ...$shutdown_commands.hibernate
# alias 'system sleep' = run-external $shutdown_commands.sleep

alias lstr = lstr -g

alias `ssh marlin` = ssh bcfelix@marlin.cs.colostate.edu -t 'nu'
alias `sync marlin` = rclone bisync --conflict-resolve newer ~/School marlin:/s/bach/g/under/bcfelix/School
alias sync = rclone bisync --conflict-resolve newer

if $nu.os-info.name == "windows" {
    def zed [path: path] {
        let path = if ($path | is-empty) {
            $env.PWD
        } else {
            $path | path expand
        }
        job spawn { || ^zed $path }
    }
}

# alias m = nu --config ~/Projects/dotfiles/nushell/ext-config.nu -e 'print banner'
alias m = overlay use ~/Projects/dotfiles/nushell/modules
alias mm = overlay hide modules
alias b = overlay use ~/Projects/dotfiles/nushell/bios
alias bb = overlay hide bios

let exes = match $nu.os-info.name {
    "windows" => {
        hey: 'hey.exe'
        spewcap2: 'spewcap2.exe'
        bar: 'bar.exe'
        tree: 'tree.exe'
    }
    "macos" | "linux" => {
        # rusty-gpt: 'rusty-gpt'
        hey: 'hey'
        spewcap2: 'spewcap2'
        bar: 'bar'
        tree: 'tree'
    }
}

def `eject installers` [] {
    if $nu.os-info.name != "macos" {
        error make -u { msg: "Eject installers only supported on macOS" }
    }
    let installers = sys disks | where type == hfs | get mount
    for installer in $installers {
        diskutil unmount $installer
    }
}

alias hey = ^$exes.hey -p ~/Arrowhead/Files/Prompts/gpt_prompt.txt
alias askvim = ^$exes.hey -p ~/Arrowhead/Files/Prompts/askvim_prompt.txt
alias eg = ^$exes.hey -p ~/Arrowhead/Files/Prompts/eg_prompt.txt
# alias chat = ^$exes.rusty-gpt -p ~/Arrowhead/Files/Prompts/chat_prompt.txt
# alias gpt = ^$exes.rusty-gpt -p ~/Arrowhead/Files/Prompts/gpt_prompt.txt
# alias teach = ^$exes.rusty-gpt -p ~/Arrowhead/Files/Prompts/teach_prompt.txt
# alias `what is` = ^$exes.rusty-gpt -p ~/Arrowhead/Files/Prompts/chat_prompt.txt 'What is '
# alias `what are` = ^$exes.rusty-gpt -p ~/Arrowhead/Files/Prompts/chat_prompt.txt 'What are '
# alias chef = ^$exes.rusty-gpt -p ~/Arrowhead/Files/Prompts/chef_prompt.txt

alias spew = ^$exes.spewcap2

# alias bar = ^$exes.bar

alias gsw = git switch
alias gbr = git branch
alias gcl = git clean -fd

alias bisync = rclone bisync --conflict-resolve newer --create-empty-src-dirs

def grst [] {
    git reset --hard
    git clean -fd
}

def gpsh [] {
    git add .
    git commit -m "quick update"
    git push
}

def lst [--level(-L): int = 2] {
    ^$exes.tree -C -L $level --dirsfirst --noreport -H
}

def `config nushell` [] {
    ^$env.EDITOR ~/Projects/dotfiles/nushell/config.nu
}

def `config aliases` [] {
    ^$env.EDITOR ~/Projects/dotfiles/nushell/aliases.nu
}

def `config banner` [] {
    ^$env.EDITOR ~/Projects/dotfiles/nushell/banner.nu
}

def `config gitui` [] {
    ^$env.EDITOR ~/Projects/dotfiles/gitui/key_bindings.ron
}

def `config ghostty` [] {
    ^$env.EDITOR ~/Projects/dotfiles/ghostty/config
}

def `config alacritty` [] {
    ^$env.EDITOR ~/Projects/dotfiles/alacritty/alacritty.toml
}

def `config neovim` [] {
    ^$env.EDITOR ~/Projects/dotfiles/neovim/init.lua
}

def `config helix` [] {
    ^$env.EDITOR ~/Projects/dotfiles/helix/config.toml
}

def `config winterm` [] {
    ^$env.EDITOR ~/Projects/dotfiles/windows-terminal/settings.json
}

def `config vscode` [] {
    error make -u { msg: "todo" }
}

alias jupyter = /opt/homebrew/opt/jupyterlab/bin/jupyter-lab

# alias b2sum = coreutils b2sum
# alias b3sum = coreutils b3sum
# alias base32 = coreutils base32
# alias base64 = coreutils base64
# alias basename = coreutils basename
# alias basenc = coreutils basenc
# alias cat = coreutils cat
# alias cksum = coreutils cksum
# alias comm = coreutils comm
# alias csplit = coreutils csplit
# alias cut = coreutils cut
# alias dd = coreutils dd
# alias df = coreutils df
# alias dir = coreutils dir
# alias dircolors = coreutils dircolors
# alias dirname = coreutils dirname
# alias env = coreutils env
# alias expr = coreutils expr
# alias factor = coreutils factor
# alias fmt = coreutils fmt
# alias fold = coreutils fold
# alias hashsum = coreutils hashsum
# alias head = coreutils head
# alias md5sum = coreutils md5sum
# alias nl = coreutils nl
# alias numfmt = coreutils numfmt
# alias od = coreutils od
# alias paste = coreutils paste
# alias pr = coreutils pr
# alias printenv = coreutils printenv
# alias printf = coreutils printf
# alias ptx = coreutils ptx
# alias readlink = coreutils readlink
# alias realpath = coreutils realpath
# alias rmdir = coreutils rmdir
# alias sha1sum = coreutils sha1sum
# alias sha224sum = coreutils sha224sum
# alias sha256sum = coreutils sha256sum
# alias sha3-224sum = coreutils sha3-224sum
# alias sha3-256sum = coreutils sha3-256sum
# alias sha3-384sum = coreutils sha3-384sum
# alias sha3-512sum = coreutils sha3-512sum
# alias sha384sum = coreutils sha384sum
# alias sha3sum = coreutils sha3sum
# alias sha512sum = coreutils sha512sum
# alias shake128sum = coreutils shake128sum
# alias shake256sum = coreutils shake256sum
# alias shred = coreutils shred
# alias shuf = coreutils shuf
# alias sum = coreutils sum
# alias tac = coreutils tac
# alias tail = coreutils tail
# alias tr = coreutils tr
# alias truncate = coreutils truncate
# alias tsort = coreutils tsort
# alias unexpand = coreutils unexpand
# alias unlink = coreutils unlink
# alias vdir = coreutils vdir
# alias wc = coreutils wc
# alias yes = coreutils yes
