# ---------------------------------------------------------------------------- #
#                                   system.nu                                  #
# ---------------------------------------------------------------------------- #

# export def copy [] {

# }

export def shutdown [] {
    run-external 'shutdown' '/s' '/t' '0'
}

export def reboot [] {
    run-external 'shutdown' '/r' '/t' '0'
}

export alias restart = reboot