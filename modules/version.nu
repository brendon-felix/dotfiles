# ---------------------------------------------------------------------------- #
#                                  version.nu                                  #
# ---------------------------------------------------------------------------- #

# plugin use semver

export def "version check" [] {
    let installed = version | get version
    let info = cargo info -q nu
    let latest = $info | lines | parse "{key}: {value}" | where key == "version" | get value | first | str trim
    let current = ($latest == $installed)
    {
        channel: "release",
        current: $current,
        latest: $latest,
    }
}

