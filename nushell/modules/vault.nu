# ---------------------------------------------------------------------------- #
#                                   vault.nu                                   #
# ---------------------------------------------------------------------------- #

def `get vault-path` [] {
    try {
        sys disks | where device == Vault | first | get mount
    } catch {
        error make -u { msg: "Vault not available" }
    }
}

export def --env main [] {
    let vault_path = get vault-path
    cd $vault_path
}

export def `vault sync-arrowhead` [] {
    let vault_path = get vault-path
    let vault_arrowhead = ($vault_path | path join 'Arrowhead')
    rclone bisync --conflict-resolve newer ~/Arrowhead $vault_arrowhead -v
}

export def --env `vault eject` [] {
    let vault_path = get vault-path
    if ($env.PWD | str starts-with $vault_path) {
        cd ~
    }
    if $nu.os-info.name == 'macos' {
        diskutil unmount $vault_path
    } else if $nu.os-info.name == 'linux' {
        umount $vault_path
    } else {
        error make -u { msg: "Vault eject not supported" }
    }
}

