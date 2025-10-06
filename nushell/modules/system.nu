
# ---------------------------------------------------------------------------- #
#                                   system.nu                                  #
# ---------------------------------------------------------------------------- #

const shutdown_commands = if $nu.os-info.name == "windows" {
    {
        restart: ['shutdown' '/r' '/t' '0']
        shutdown: ['shutdown' '/s' '/t' '0']
        hibernate: ['shutdown' '/h' '/t' '0']
        # sleep: 'rundll32.exe powrprof.dll,SetSuspendState 0,1,0'
    }
} else {
    {
        restart: ['sudo' 'shutdown' '-r' 'now']
        shutdown: ['sudo' 'shutdown' '-h' 'now']
        hibernate: ['systemctl' 'hibernate']
        # sleep: 'systemctl suspend'
    }
}
export alias restart = run-external ...$shutdown_commands.restart
export alias reboot = run-external ...$shutdown_commands.reboot
export alias shutdown = run-external ...$shutdown_commands.shutdown
export alias hibernate = run-external ...$shutdown_commands.hibernate
# alias 'system sleep' = run-external $shutdown_commands.sleep
