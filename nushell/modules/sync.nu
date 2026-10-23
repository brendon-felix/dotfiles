
export def --wrapped `sync init` [
    path1: path
    path2: path
    --dry-run(-d)
    ...rest
] {
    if $dry_run {
        ^rclone bisync --resync --conflict-resolve newer --verbose $path1 $path2 --dry-run ...$rest
    } else {
        ^rclone bisync --resync --conflict-resolve newer --verbose $path1 $path2 ...$rest
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

# fermi's ~/Vault is also a Syncthing folder; its bookkeeping files must not round-trip.
const fermi_excludes = [
    '.stfolder/**' '.stversions/**' '.stignore' '**/.syncthing.*.tmp' '**/~syncthing~*.tmp'
    '.DS_Store' '._*' 'desktop.ini' 'Thumbs.db'
]

export def --wrapped `sync fermi` [
    --resync # Establish the baseline: first run, or when bisync asks for it
    ...rest
] {
    let mode = if $resync { [--resync --resync-mode newer] } else { [--resilient --recover --max-lock 30m] }
    let excludes = $fermi_excludes | each {|pattern| [--exclude $pattern] } | flatten
    ^rclone bisync ~/Vault/ fermi:Vault/ --conflict-resolve newer --verbose ...$mode ...$excludes ...$rest
}
