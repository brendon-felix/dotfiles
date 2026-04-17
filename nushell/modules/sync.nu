
export def `sync init` [
    path1: path
    path2: path
    --dry-run(-d)
] {
    if $dry_run {
        rclone bisync --resync --conflict-resolve newer --verbose $path1 $path2 --dry-run
    } else {
        rclone bisync --resync --conflict-resolve newer --verbose $path1 $path2
    }
}

export def main [
    path1: path
    path2: path
] {
    rclone bisync --conflict-resolve newer --verbose $path1 $path2
}

export def `sync vault` [] {
    if not ('/Volumes/Vault/' | path exists) {
        error make -u {msg: "Vault drive not found"}
    }
    rclone bisync --conflict-resolve newer --verbose ~/Vault/ /Volumes/Vault/ --exclude '.DS_Store' --exclude '._*' --exclude '.Spotlight-V100/**' --exclude '.fseventsd/**' --exclude '.TemporaryItems/**' --exclude '.Trashes/**' --exclude '.DocumentRevisions-V100/**' --exclude 'System Volume Information/**' --exclude '$RECYCLE.BIN/**'
}

export def `sync marlin` [] {
    main ~/School marlin:/s/bach/g/under/bcfelix/School
}
