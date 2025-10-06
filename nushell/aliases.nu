alias r = nu ./run.nu
alias du = dust
alias vim = nvim
alias untar = tar -xvf
alias py = python3

alias `ssh marlin` = ssh bcfelix@marlin.cs.colostate.edu -t 'nu'

alias `reload modules` = overlay use ($nu.data-dir | path join 'modules');
alias `reload bios-modules` = overlay use ($nu.data-dir | path join 'bios');
