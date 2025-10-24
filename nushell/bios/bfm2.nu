# ---------------------------------------------------------------------------- #
#                                    bfm2.nu                                   #
# ---------------------------------------------------------------------------- #

use ../modules/format.nu 'format hex'
use ../modules/paint.nu main
use ../modules/splash.nu *
use ../modules/path.nu 'path stem-append'

const BIOS_CONFIGS = {
    springs: {
        id: "X60"
        name: "Springs"
        repo: "HpSpringsWks"
        build_script: "HpBldSprings.bat"
        bios_id_file: 'MultiProject\X60Steamboat\BLD\BiosId.env'
    }
    winters: {
        id: "U61"
        name: "Winters"
        repo: "HpWintersWks"
        build_script: "HpBldBlizzard.bat"
        bios_id_file: 'MultiProject\U61Blizzard\BLD\BiosId.env'
    }
    glacier: {
        id: "U60"
        name: "Glacier"
        repo: "HpWintersWks"
        build_script: "HpBldGlacier.bat"
        bios_id_file: 'MultiProject\U60Glacier\BLD\BiosId.env'
    }
    avalanche: {
        id: "U65"
        name: "Avalanche"
        repo: "HpAvalancheWks"
        build_script: "HpBiosBuild.bat"
        bios_id_file: 'BLD\RSPS\Avalanche\BiosId.env'
    }
}

const BIOS_DEV_PATH = 'C:\Users\felixb\BIOS'
const LOCAL_BOOTLEGS_PATH = 'C:\Users\felixb\BIOS\Bootlegs'
const NETWORK_BOOTLEGS_PATH = '\\wks-file.ftc.rd.hpicorp.net\MAIN_LAB\SHARES\LAB\Brendon Felix\Bootlegs'

def "nu-complete bios-platforms" [] {
    $BIOS_CONFIGS | keys
}

def find-binary [path: path] {
    try {
        ls $path | where name =~ '^(?i)(?!.*pvt).*?(32|64).*\.bin$' | sort-by modified | last
    } catch {
        null
    }
}

def set-version [file: path, version?: int] {
    if not ($file | path exists) {
        print $"(ansi red)BiosId.env file not found at ($file | path basename)(ansi reset)"
        error make -u { msg: "BiosId.env file not found" }
    }
    let curr_version_str = open $file | lines | parse "VERSION_FEATURE{_}={version}" | str trim | get version | first
    let curr_version = $curr_version_str | decode hex | into int
    let new_version = match $version {
        null => (($curr_version - 1) mod 100)
        $v => ($v mod 100)
    }
    print $"(ansi yellow)Setting feature version: ($curr_version | into string | paint grey46) -> ($new_version | into string | paint blue)(ansi reset)"
    let new_contents = open $file | lines | each {|e|
        if ($e | str contains VERSION_FEATURE) {
            $e | str replace $curr_version_str ($new_version | format hex -r)
        } else { $e }
    } | str join "\n"
    $new_contents + "\n" | save -f $file
}

export def --env `bios build` [
    platform: string@"nu-complete bios-platforms"
    --release(-r)             # Build a release binary
    --tree(-t): path          # Specify a specific tree to use
    --no-decrement(-d)        # Don't decrement the feature number
    --set-version(-v): int    # Set the feature version number directly
]: nothing -> path {
    let config = $BIOS_CONFIGS | get $platform
    let repo_path = match $tree {
        null => ($BIOS_DEV_PATH | path join $config.repo)
        $t => {
            if not ($t | path exists) {
                error make {
                    msg: "Specified tree not found"
                    label: {
                        text: "Tree not found"
                        span: (metadata $tree).span
                    }
                }
            }
            $t
        }
    }
    let cmd = match $release {
        true => [$config.build_script, 'r']
        false => [$config.build_script]
    }
    let type_str = if $release { "RELEASE" } else { "DEBUG" }
    let platform_pkg = $repo_path | path join 'HpPlatformPkg'
    let bios_id_file = $platform_pkg | path join $config.bios_id_file
    if $set_version != null {
        set-version $bios_id_file $set_version
    } else if not $no_decrement {
        set-version $bios_id_file
    }
    print $"(ansi purple)Building ($type_str) binary...(ansi reset)"
    try {
        do { cd $platform_pkg; run-external ...$cmd }
        # let build = find-binary ($repo_path | path join 'HpPlatformPkg' 'BLD' 'FV')
        # let var_name = $"($config.name | str upcase)_BUILD"
        # load-env {$var_name: $build.name}
    } catch {
        "Build failed" | splash red -s 3
        error make -u {msg: "Build failed"}
    }
}

export def `bios bootleg` [
    platform: string@"nu-complete bios-platforms"
    --append(-a): string
    --upload(-u)
    --upload-existing(-e)
    --select(-s)
    --tree(-t): path
] {
    let config = $BIOS_CONFIGS | get $platform
    if $upload_existing {
        let files = ls ($LOCAL_BOOTLEGS_PATH | path join $config.name) | where name =~ '^(?i)(?!.*pvt).*?(32|64).*\.bin$' | sort-by -r modified
        if ($files | is-empty) {
            error make -u { msg: "No matching binaries found" }
        }
        let binary = if $select {
            let idx = $files | get name | path basename | input list -f --index "Select a binary"
            if $idx == null {
                error make -u { msg: "No binary selected" }
            }
            let binary = $files | get $idx
            print $"Selected binary in bootlegs folder: (ansi blue)($binary.name | path basename)(ansi reset)"
            print $"Size: ($binary.size | format filesize MiB)"
            $binary
        } else {
            let binary = $files | first
            print $"Found recent binary in bootlegs folder: (ansi blue)($binary.name | path basename)(ansi reset)"
            print $"Size: ($binary.size | format filesize MiB)"
            $binary
        }
        cp $binary.name ($NETWORK_BOOTLEGS_PATH | path join $config.name ($binary.name | path basename))
        print $"Uploaded existing bootleg (ansi blue)($binary.name | path basename)(ansi reset) to network bootlegs folder"
    } else {
        print $"(ansi purple)Saving binary...(ansi reset)"
        let binary = match $tree {
            null => (find-binary ($BIOS_DEV_PATH | path join $config.repo 'HpPlatformPkg' 'BLD' 'FV'))
            $t => (find-binary ($t | path join 'HpPlatformPkg' 'BLD' 'FV'))
        }
        if $binary == null {
            error make -u { msg: "No binary found in build folder" }
        }
        print $"Found binary in build folder: (ansi blue)($binary.name | path basename)(ansi reset)"
        print $"Size: ($binary.size | format filesize MiB)"
        let basename = match $append {
            null => ($binary.name | path basename)
            $a => ($binary.name | path basename | path stem-append $a)
        }
        cp $binary.name ($LOCAL_BOOTLEGS_PATH | path join $config.name $basename)
        print $"Saved bootleg (ansi blue)($basename)(ansi reset) to local bootlegs folder"
        if $upload {
            cp $binary.name ($NETWORK_BOOTLEGS_PATH | path join $config.name $basename)
            print $"Uploaded bootleg (ansi blue)($basename)(ansi reset) to network bootlegs folder"
        }
    }
}

def "nu-complete bootlegs" [context: string] {
    let platform = $context | split words | get 2
    let dir = $LOCAL_BOOTLEGS_PATH | path join ($BIOS_CONFIGS | get $platform).name
    let completions = ls $dir
        | where name =~ '^(?i)(?!.*pvt).*?(32|64).*\.bin$'
        | sort-by -r modified
        | get name
        | path basename
    {
        options: { sort: false }
        completions: $completions
    }
}
export def `bios flash` [
    platform: string@"nu-complete bios-platforms"
    --bootleg(-l): string@"nu-complete bootlegs"
    --select(-s)
    --path(-p): path
    --no-info(-n)
] {
    let config = $BIOS_CONFIGS | get $platform
    let binary = match $path {
        null => {
            let bin_info = if $bootleg != null {
                let path = ($LOCAL_BOOTLEGS_PATH | path join $config.name $bootleg)
                { path: $path, type: "bootleg" }
            } else {
                let path = ($BIOS_DEV_PATH | path join $config.repo 'HpPlatformPkg' 'BLD' 'FV')
                { path: $path, type: "build" }
            }
            let binary = find-binary $bin_info.path
            if $binary == null {
                error make -u { msg: "No binary found in build folder" }
            }
            if not $no_info {
                print $"Found binary in ($bin_info.type) folder: (ansi blue)($binary.name | path basename)(ansi reset)"
                print $"Size: ($binary.size | format filesize MiB)"
            }
            $binary
        }
        $p => {
            let binary = find-binary $p
            if $binary == null {
                error make -u { msg: "No binary found at specified path" }
            }
            if not $no_info {
                print $"Found specified binary: (ansi blue)($binary.name | path basename)(ansi reset)"
                print $"Size: ($binary.size | format filesize MiB)"
            }
            $binary
        }
    }
    print $"(ansi purple)Flashing binary...(ansi reset)"
    try {
        do {dpcmd --batch $binary.name --verify}
        print ""
        "Flash successful" | splash green -s 3
    } catch {
        print ""
        "Flash failed" | splash red -s 3
        error make -u {msg: "Flash failed"}
    }
}

export def `bios batch` [
    platform: string@"nu-complete bios-platforms"
    --release(-r)             # Build a release binary
    --tree(-t): path          # Specify a specific tree to use
    --no-decrement(-d)        # Don't decrement the feature number
    --set-version(-v): int    # Set the feature version number directly
    --append(-a): string
    --upload(-u)
    --flash(-f)
    --bootleg(-l)
    --path(-p): path
] {
    bios build $platform --release=$release --tree=$tree --no-decrement=$no_decrement --set-version=$set_version
    bios bootleg $platform --append=$append --upload=$upload --tree=$tree
    if $flash {
        bios flash $platform --bootleg --path=$path --no-info
    } else {
        print $"(ansi yellow)Skipped flash(ansi reset)"
    }
}
