
export def `eject installers` [] {
    if $nu.os-info.name != "macos" {
        error make -u { msg: "Eject installers only supported on macOS" }
    }
    let installers = sys disks | where type == hfs | get mount
    for installer in $installers {
        diskutil unmount $installer
    }
}
