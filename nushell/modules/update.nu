
# ---------------------------------------------------------------------------- #
#                                   update.nu                                  #
# ---------------------------------------------------------------------------- #

use debug.nu *
use color.nu 'ansi apply'
use procedure.nu 'procedure new-task'

export def `update imports` [] {
    let path = '~' | path join Projects nushell-scripts modules | path expand
    let modules = ls $path | where name =~ '\.nu$' | get name | path basename | where $it != mod.nu
    match ($modules | is-empty) {
        true => {
            error make -u {
                msg: $"no modules found in ($path | path expand)",
            }
        }
        false => {
            let imports = $modules | each {|e| $"export use ($e) *" }
            procedure new-task $"Saving ($modules | length | into string | ansi apply blue) imports to ('modules/mod.nu' | ansi apply blue)" {
                $imports | save -f ($path | path join mod.nu)
            }
        }
    }
}

