# ---------------------------------------------------------------------------- #
#                                   update.nu                                  #
# ---------------------------------------------------------------------------- #

use procedure.nu 'procedure new-task'

export def `update imports` [] {
    procedure new-task "Updating module imports" {
        procedure new-task "Creating new mod file" {
            if ($env.IMPORTS_FILE | path exists) {
                rm $env.IMPORTS_FILE
            } else {
                touch $env.IMPORTS_FILE
            }
        }
        procedure new-task "Writing module imports to mod file" {
            let modules = (ls-builtin ~/Projects/nushell-scripts/modules/ | sort-by type | get name | path basename)
            for m in $modules {
                $"use modules/($m) *\n" | save -a $env.IMPORTS_FILE
            }
        }
    }
}
