
# ---------------------------------------------------------------------------- #
#                                   update.nu                                  #
# ---------------------------------------------------------------------------- #

use debug.nu *
use paint.nu main
use procedure.nu 'procedure new-task'

export def `update imports` [] {
    let path = '~/Projects/dotfiles/nushell/modules' | path expand
    let modules = ls $path | where name =~ '\.nu$' | get name | path basename | where $it != mod.nu
    match ($modules | is-empty) {
        true => {
            error make -u {
                msg: $"no modules found in ($path | path expand)",
            }
        }
        false => {
            let imports = $modules | each {|e| $"export use ($e) *" }
            procedure new-task $"Saving ($modules | length | into string | paint blue) imports to ('modules/mod.nu' | paint blue)" {
                $imports | save -f ($path | path join mod.nu)
            }
        }
    }
}
