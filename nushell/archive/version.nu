
# ---------------------------------------------------------------------------- #
#                                  version.nu                                  #
# ---------------------------------------------------------------------------- #

export alias `builtin version-check` = version check

export def "version check" [] {
    let nu_version = var load nu_version
    if $nu_version == null {
        version full-check
    } else if $nu_version.latest == null {
        version full-check
    } else if ((date now) > ($nu_version.last_checked + 1day)) {
        version full-check
    } else {
        let installed = version | get version
        let current = ($nu_version.latest == $installed)
        {
            channel: "release",
            current: $current,
            latest: $nu_version.latest,
        }
    }
}

export def `version full-check` [] {
    let installed = version | get version
    let info = cargo info -q nu
    let latest = $info | lines | parse "{key}: {value}" | where key == "version" | get value | first | str trim
    # let latest = cargo search -q --limit 1 nu | lines | parse 'nu = "{version}"{_}' | first | get version
    let current = ($latest == $installed)
    var update {nu_version: {latest: $latest, last_checked: (date now)}} 
    {
        channel: "release",
        current: $current,
        latest: $latest,
    }
}

