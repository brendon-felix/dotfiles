
# ---------------------------------------------------------------------------- #
#                                  shadows.nu                                  #
# ---------------------------------------------------------------------------- #

export alias config-nu-builtin = config nu

# Edit nu configurations.
export def `config nu` [
    --default(-d)   # Print the internal default `config.nu` file instead.
    --doc(-s)       # Print a commented `conifg.nu` with documentation instead.
    --builtin(-b)   # Edit the actual built-in `config.nu` file instead of the custom one.
] {
    if $default {
        config-nu-builtin --default
    } else if $doc {
        config-nu-builtin --doc | nu-highlight | less -R
    } else if $builtin {
        config-nu-builtin
    } else {
        cd ~/Projects/nushell-scripts
        ^$env.EDITOR config.nu
    }
}

# export alias ls-builtin = ls
#
# # List the filenames, sizes, and modification times of items in a directory.
# export def ls [
#     --all (-a),         # Show hidden files
#     --full-paths (-f),  # display paths as absolute paths
#     ...pattern: glob,   # The glob pattern to use.
# ] {
#     let pattern = if ($pattern | is-empty) { [ '.' ] } else { $pattern }
#     let table = (ls
#         --all=$all
#         --short-names=(not $full_paths)
#         --full-paths=$full_paths
#         ...$pattern
#     )
#     match $nu.is-interactive {
#         true => ($table | sort-by type name -i | grid -c)
#         false => $table
#     }
# }
#
