# ---------------------------------------------------------------------------- #
#                                 env-config.nu                                #
# ---------------------------------------------------------------------------- #

# ---------------------------------- modules --------------------------------- #

source config.nu
source sys-commands.nu

use modules *
use completions *
use bios *


$env.MODULES_LOADED = true

# ---------------------------------- banner ---------------------------------- #

# if $nu.is-interactive {
#     match (sys host | get hostname) {
#         'kepler' => (print banner header)
#         _ => (print banner memory)
#     }
# }

