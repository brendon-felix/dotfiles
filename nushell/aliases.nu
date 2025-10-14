alias r = nu ./run.nu
alias du = dust
alias vim = nvim
alias untar = tar -xvf
alias py = python3

alias `ssh marlin` = ssh bcfelix@marlin.cs.colostate.edu -t 'nu'

alias `reload modules` = overlay use ($nu.data-dir | path join 'modules');
alias `reload bios-modules` = overlay use ($nu.data-dir | path join 'bios');

alias fzf = fzf --height ~80% --layout=reverse --preview 'bat --theme=ansi --style=numbers --color=always -r 1:100 --style plain {}' --preview-window=right:60% --bind $"enter:become\(($env.EDITOR) {+}\)"

alias `bat update` = bat cache --build

alias browse = yazi
