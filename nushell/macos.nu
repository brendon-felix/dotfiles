$env.ANDROID_HOME = '~/Library/Android/sdk' | path expand
$env.ANDROID_NDK_ROOT = '~/Library/Android/sdk/ndk/27.3.13750724' | path expand
$env.JAVA_HOME = '/Applications/Android Studio.app/Contents/jbr/Contents/Home'

# # Android
# export ANDROID_HOME=/Users/felixb/Library/Android/sdk
# export ANDROID_NDK_ROOT=/Users/felixb/Library/Android/sdk/ndk/27.3.13750724
# export PATH="$JAVA_HOME/bin:$PATH"

export def `eject installers` [] {
    if $nu.os-info.name != "macos" {
        error make -u { msg: "Eject installers only supported on macOS" }
    }
    let installers = sys disks | where type == hfs | get mount
    for installer in $installers {
        diskutil unmount $installer
    }
}
