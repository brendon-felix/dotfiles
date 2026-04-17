alias c = clear
alias r = nu ./run.nu
alias du = dust
alias vim = nvim
alias iperf = iperf3
alias untar = tar -xvf
alias py = python3
alias tick = automatick
alias sr = subroutine-cli

# alias `ssh marlin` = ssh bcfelix@marlin.cs.colostate.edu -t 'nu'
# alias `ssh fermi` = ssh felixb@100.112.215.8
# alias `ssh server` = ssh felixb@100.112.215.8

alias `reload modules` = overlay use ($nu.data-dir | path join 'modules');
alias `reload bios-modules` = overlay use ($nu.data-dir | path join 'bios');

alias fzf = fzf --height=~80% --layout=reverse --preview 'bat --style=numbers --color=always -r 1:100 --style plain {}' --preview-window=right:60% --bind $"enter:become\(($env.EDITOR) {+}\)"

alias `bat update` = bat cache --build

alias `what is` = hey what is
alias `what are` = hey what are
alias `explain` = hey explain

alias guidgen = `C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\guidgen.exe`
