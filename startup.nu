# ---------------------------------------------------------------------------- #
#                                  startup.nu                                  #
# ---------------------------------------------------------------------------- #

mut error_occurred = false

cd ~/Projects/nushell-scripts
print "Updating nushell scripts... "
try {
    git pull --rebase
    touch ~/Projects/nushell-scripts/commands.nu
} catch {|err|
    print -e $"(ansi yellow)Warning:(ansi reset) Could not update Nushell scripts"
    pause
}
print $"(ansi green)Done(ansi reset)"

sleep 1sec