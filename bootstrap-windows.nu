if not (is-admin) {
    error make -u {msg: "this script requires admin privileges"}
}

let winget_packages = [
    # languages
    OpenJS.NodeJS
    Python.Python.3.13
    # compilers
    LLVM.LLVM
    BurntSushi.ripgrep.MSVC
    Kitware.CMake
    # applications
    Neovim.Neovim
    StephanDilly.gitui
    # utilities
    Git.Git
    Gyan.FFmpeg
    Rclone.Rclone
    ajeetdsouza.zoxide
    jqlang.jq
    junegunn.fzf
    oschwartz10612.Poppler
    sharkdp.bat
    sharkdp.fd
    7zip.7zip
    ImageMagick.ImageMagick
    sxyazi.yazi
]
for package in $winget_packages {
    print $"Installing winget package: ($package)"
    try { winget install $package --accept-source-agreements --accept-package-agreements } catch {
        print -e "Could not install winget package"
    }
    print ""
}

let cargo_packages = [
    du-dust
    lstr
    nu_plugin_highlight
    nu_plugin_ls_colorize
    numbat_cli
    vivid
]
for package in $cargo_packages {
    print $"Installing cargo package: ($package)"
    try { cargo install $package } catch { print -e "Could not install cargo package" }
    print ""
}

let cargo_plugins = ls ~/.cargo/bin/nu_plugin*.exe | get name
let builtin_plugins = [
    nu_plugin_gstat.exe
    nu_plugin_inc.exe
] | each {|e| ($nu.current-exe | path dirname) | path join $e }

for plugin in ($cargo_plugins | append $builtin_plugins | uniq) {
    print $"Registering plugin: ($plugin)"
    try { plugin add $plugin } catch { print -e "Could not add plugin" }
    print ""
}

let projects = [
    dotfiles
    hey
    spewcap
    bar
    byte-converter
]
if not ('~/Projects' | path exists) {
    print "Creating ~/Projects directory"
    try { mkdir ~/Projects }
}
cd ~/Projects
for project in $projects {
    if not ('~/Projects' | path join $project | path exists) {
        let url = $"https://github.com/brendon-felix/($project).git"
        print $"Cloning ($url)"
        try { git clone $url } catch { print -e "Could not clone repo" }
    } else {
        print $"Skipping ($project)"
    }
    print ""
}
cd -

def symlink [
    source: path
    link: path
] {
    if ($link | path expand | path exists) {
        if (input -n 1 $"Path ($link) already exists. Overwrite? [y/N]: ") in ['y', 'Y'] {
            print $"Removing existing ($link | path basename)"
            rm -r $link
        } else {
            print $"Skipping ($source | path basename)"
            return
        }
    }
    if ($source | path type) == dir {
        print $"Creating directory symlink ($link) -> ($source)"
        ^mklink /D ($link | path expand) ($source | path expand)
    } else {
        print $"Creating file symlink ($link) -> ($source)"
        ^mklink ($link | path expand) ($source | path expand)
    }
}

let symlinks = [
    [target    link];
    [neovim    ~/AppData/Local/nvim]
    [nushell   ~/AppData/Roaming/nushell]
    [zed       ~/AppData/Roaming/zed]
    [alacritty ~/AppData/Roaming/alacritty]
    [bat       ~/AppData/Roaming/bat]
    [helix     ~/AppData/Roaming/helix]
    [windows-terminal/settings.json ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json]
]
for symlink in $symlinks {
    let target = ('~/Projects/dotfiles' | path join $symlink.target | path expand -n)
    let link = ($symlink.link | path expand -n)
    if not ($target | path exists) {
        print -e $"target path does not exist: ($target)"
        continue
    }
    print $"Creating symlink: ($link) -> ($target)"
    try { symlink $target $link } catch { print -e "Could not create link" }
    print ""
}
