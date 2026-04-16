# ---------------------------------------------------------------------------- #
#                                    bfm2.nu                                   #
# ---------------------------------------------------------------------------- #

use ../modules/format.nu 'format hex'
use ../modules/paint.nu main
use ../modules/splash.nu *
use ../modules/path.nu 'path stem-append'

const BIOS_DEV_PATH = 'C:\Users\felixb\BIOS'
const LOCAL_BOOTLEGS_PATH = 'C:\Users\felixb\BIOS\Bootlegs'
const NETWORK_BOOTLEGS_PATH = '\\wks-file.ftc.rd.hpicorp.net\MAIN_LAB\SHARES\LAB\Brendon Felix\Bootlegs'

def `cursor off` [] {
    print -n $"(ansi cursor_off)"
}

def `cursor on` [] {
    print -n $"(ansi cursor_on)"
}

def "nu-complete bios-platforms" [] {
    $env.BIOS_CONFIGS | keys
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
        print $"BiosId.env file ('not found' | paint red) at ($file | path basename | paint grey)"
        error make -u { msg: "BiosId.env file not found" }
    }
    let curr_version_str = open $file | lines | parse "VERSION_FEATURE{_}={version}" | str trim | get version | first
    let curr_version = $curr_version_str | decode hex | into int
    let new_version = match $version {
        null => (($curr_version - 1) mod 100)
        $v => ($v mod 100)
    }
    print $"Setting ('feature version' | paint blue): ($curr_version | paint grey46) -> ($new_version | paint cyan)"
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
    let config = $env.BIOS_CONFIGS | get $platform
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
    let type_str = if $release { "release" | paint green_bold } else { "debug" | paint yellow_bold }
    let platform_pkg = $repo_path | path join 'HpPlatformPkg'
    let bios_id_file = $platform_pkg | path join $config.bios_id_file
    if $set_version != null {
        set-version $bios_id_file $set_version
    } else if not $no_decrement {
        set-version $bios_id_file
    }
    print $"Building ($type_str) binary..."
    # let max_length = 160
    let term_width = term size | get columns
    let max_length = [160 $term_width] | math min
    cursor off
    try {
        do {
            cd $platform_pkg
            run-external ...$cmd o+e>| lines | each {|line|
                if ($line =~ 'Active Platform') {
                    let platform = $line | split row ' ' | last | path basename
                    print $"Building for package: ($platform | paint purple)"
                } else if ($line =~ 'fatal') {
                    print ($line | paint red)
                    error make -u {msg: "Fatal error during build"}
                } else if ($line =~ 'Building \.\.\. ') {
                    let parsed = $line | parse "{_}Building ... {path} {arch}" | first
                    let path = $parsed.path | path relative-to $repo_path
                    print $"Building ($parsed.arch | fill -w 6) ($path | path highlight)"
                } else if ($line =~ 'Generating') and not ($line =~ 'Generating code') and not ($line =~ 'Generating makefile') {
                    let parsed = $line | parse "{_}Generating {rest}" | first
                    print $"Generating ($parsed.rest | paint blue)"
                } else if ($line =~ 'EDKII') and ($line =~ 'success') {
                    print ($line | paint green)
                } else {
                    print -n ('...' | paint attr_blink) "\r"
                }
            } | ignore
        }
        # do {
        #     cd $platform_pkg
        #     run-external ...$cmd o+e>| lines | print
        # } | ignore
        cursor on
        print ""
    } catch {|e|
        print $e.rendered
        cursor on
        print ""
        # "Build failed" | splash red -s 3
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
    let config = $env.BIOS_CONFIGS | get $platform
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
            print $"Selected binary in bootlegs folder: ($binary.name | path basename | paint blue)"
            print $"Size: ($binary.size | format filesize MiB | paint cyan)"
            $binary
        } else {
            let binary = $files | first
            print $"Found recent binary in bootlegs folder: ($binary.name | path basename | paint blue)"
            print $"Size: ($binary.size | format filesize MiB | paint cyan)"
            $binary
        }
        cp $binary.name ($NETWORK_BOOTLEGS_PATH | path join $config.name ($binary.name | path basename))
        print $"Uploaded existing bootleg ($binary.name | path basename | paint blue) to network bootlegs folder"
    } else {
        print $"(ansi purple)Saving binary...(ansi reset)"
        let binary = match $tree {
            null => (find-binary ($BIOS_DEV_PATH | path join $config.repo 'HpPlatformPkg' 'BLD' 'FV'))
            $t => (find-binary ($t | path join 'HpPlatformPkg' 'BLD' 'FV'))
        }
        if $binary == null {
            error make -u { msg: "No binary found in build folder" }
        }
        print $"Found binary in build folder: ($binary.name | path basename | paint blue)"
        print $"Size: ($binary.size | format filesize MiB | paint cyan)"
        let basename = match $append {
            null => ($binary.name | path basename)
            $a => ($binary.name | path basename | path stem-append $a)
        }
        cp $binary.name ($LOCAL_BOOTLEGS_PATH | path join $config.name $basename)
        print $"Saved bootleg ($basename | paint blue) to local bootlegs folder"
        if $upload {
            cp $binary.name ($NETWORK_BOOTLEGS_PATH | path join $config.name $basename)
            print $"Uploaded bootleg ($basename | paint blue) to network bootlegs folder"
        }
    }
}

def "nu-complete bootlegs" [context: string] {
    let platform = $context | split words | get 2
    let dir = $LOCAL_BOOTLEGS_PATH | path join ($env.BIOS_CONFIGS | get $platform).name
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
    --autoselect-bootleg
    --path(-p): path
    --no-info(-n)
] {
    let config = $env.BIOS_CONFIGS | get $platform
    let binary = match $path {
        null => {
            let bin_info = if $bootleg != null {
                let path = ($LOCAL_BOOTLEGS_PATH | path join $config.name $bootleg)
                { path: $path, type: "bootleg" }
            } else if $autoselect_bootleg {
                let path = ($LOCAL_BOOTLEGS_PATH | path join $config.name)
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
                print $"Found binary in ($bin_info.type | paint purple) folder: ($binary.name | path basename | paint blue)"
                print $"Size: ($binary.size | format filesize MiB | paint cyan)"
            }
            $binary
        }
        $p => {
            let binary = find-binary $p
            if $binary == null {
                error make -u { msg: "No binary found at specified path" }
            }
            if not $no_info {
                print $"Found specified binary: ($binary.name | path basename | paint blue)"
                print $"Size: ($binary.size | format filesize MiB | paint cyan)"
            }
            $binary
        }
    }
    print ("Flashing binary..." | paint purple)
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
    --path(-p): path
] {
    bios build $platform --release=$release --tree=$tree --no-decrement=$no_decrement --set-version=$set_version
    bios bootleg $platform --append=$append --upload=$upload --tree=$tree
    if $flash {
        bios flash $platform --autoselect-bootleg --path=$path --no-info
    } else {
        print ("Skipped flashing" | paint yellow)
    }
}
