# ---------------------------------------------------------------------------- #
#                                  version.nu                                  #
# ---------------------------------------------------------------------------- #

# plugin use semver

export alias `builtin version-check` = version check

export def "version check" [] {
    let installed = version | get version
    let info = cargo info -q nu
    let latest = $info | lines | parse "{key}: {value}" | where key == "version" | get value | first | str trim
    # let latest = cargo search -q --limit 1 nu | lines | parse 'nu = "{version}"{_}' | first | get version
    let current = ($latest == $installed)
    {
        channel: "release",
        current: $current,
        latest: $latest,
    }
}

