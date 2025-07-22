
# ---------------------------------------------------------------------------- #
#                                   splash.nu                                  #
# ---------------------------------------------------------------------------- #

export def main [color?: any = 'default', --shorten-by(-s): int = 1, --fill(-f)] {
    $in | contain -p "comfy" | div --background=$color --position 'c' --shorten-by=$shorten_by --fill=$fill | container print
}

