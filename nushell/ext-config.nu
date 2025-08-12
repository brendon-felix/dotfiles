# ---------------------------------------------------------------------------- #
#                                 env-config.nu                                #
# ---------------------------------------------------------------------------- #

# ---------------------------------- modules --------------------------------- #

source config.nu

use modules *
use completions *
use bios *

source ('~/.sys-commands.nu' | path expand)

$env.MODULES_LOADED = true

# $env.PROMPT_COMMAND_RIGHT = { || date now | format date "%a-%d %r" }

# ---------------------------------- banner ---------------------------------- #

# if $nu.is-interactive {
#     match (sys host | get hostname) {
#         'kepler' => (print banner header)
#         _ => (print banner memory)
#     }
# }

