alias c = clear
alias r = nu ./run.nu
alias du = dust
alias vim = nvim
alias iperf = iperf3
alias untar = tar -xvf
alias py = python3
alias tick = automatick
alias sr = subroutine-cli

alias tui = cargo run -p tui
alias desktop = cargo run -p desktop
alias cli = cargo run -p cli

alias `reload modules` = overlay use ($nu.data-dir | path join 'modules');
alias `reload bios-modules` = overlay use ($nu.data-dir | path join 'bios');

alias fzf = fzf --height=~80% --layout=reverse --preview 'bat --style=numbers --color=always -r 1:100 --style plain {}' --preview-window=right:60%

alias `bat update` = bat cache --build

alias `what is` = hey what is
alias `what are` = hey what are
alias `explain` = hey explain

alias guidgen = `C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\guidgen.exe`
