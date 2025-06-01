# ---------------------------------------------------------------------------- #
#                                  startup.nu                                  #
# ---------------------------------------------------------------------------- #

mut error_occurred = false

cd ~/Projects/nushell-scripts
try {
    print "Updating nushell scripts..."
    git pull --rebase
    touch ~/Projects/nushell-scripts/commands.nu
    print $"  (ansi green)Done(ansi reset)"
} catch {|err|
    print -e $"(ansi yellow)Warning:(ansi reset) Could not update Nushell scripts"
}
