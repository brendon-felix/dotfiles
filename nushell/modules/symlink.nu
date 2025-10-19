# ---------------------------------------------------------------------------- #
#                                  symlink.nu                                  #
# ---------------------------------------------------------------------------- #

use paint.nu main

def create_symlink [
    source: path
    link: path
    --force(-f)
    --quiet
] {
    if (which ln | is-empty) { error make -u { msg: "ln command not found" } }
    if not $quiet {
        print $"Creating symlink ($link | paint red) -> ($source | paint cyan)"
    }
    mut cmd = [ln -s ($source | path expand) ($link | path expand)]
    if $force { $cmd = $cmd | append '-F' }
    run-external ...$cmd
}

export def main [
    source: path
    link: path
    --force(-f)
    --quiet(-q)
] {
    match $link {
        $l if ($l | path exists) and $force => {
            if not $quiet {
                print $"Removing existing path ($l | ls-colorize)"
            }
            create_symlink $source $link --force=$force --quiet=$quiet
        }
        $l if ($l | path exists) => {
            error make {
                msg: $"link path already exists: ($l | ls-colorize)"
                label: {
                    text: "use --force(-f) to overwrite"
                    span: (metadata $link).span
                }
            }
        }
        _ => {
            create_symlink $source $link --force=$force --quiet=$quiet
        }
    }
}
