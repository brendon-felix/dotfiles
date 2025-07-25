# ---------------------------------------------------------------------------- #
#                                    bfm.nu                                    #
# ---------------------------------------------------------------------------- #

use ../modules/format.nu 'format hex'
use ../modules/print-utils.nu countdown
use ../modules/debug.nu *
use ../modules/color.nu 'ansi apply' 


const dev_loc = 'C:\Users\felixb\BIOS'
const net_loc = '\\wks-file.ftc.rd.hpicorp.net\MAIN_LAB\SHARES\LAB\Brendon Felix\Bootlegs'

def get_repo_loc [tree, default] {
    if $tree != null {
        let loc = [$dev_loc, $tree] | path join
        if ($loc | path exists) {
            $loc
        } else {
            print $"(ansi red_bold)!(ansi reset)"
            error make {
                msg: "Specified tree not found"
                label: {
                    text: "Tree not found"
                    span: (metadata $tree).span
                }
            }
        }
    } else {
        [$dev_loc, $default] | path join
    }
}

def create_config [name, tree, default_tree, biosid_loc] {
    let repo_loc = get_repo_loc $tree $default_tree
    let pltpkg_loc = [$repo_loc, 'HpPlatformPkg'] | path join
    {
        name: $name,
        repo_loc: $repo_loc,
        pltpkg_loc: $pltpkg_loc,
        bld_path: ([$pltpkg_loc, 'BLD\FV'] | path join),
        bootleg_loc: ([$dev_loc, 'Bootlegs', $name] | path join),
        network_loc: ([$net_loc, $name] | path join),
        biosid_loc: ([$pltpkg_loc, $biosid_loc] | path join)
    }
}

def get_config [platform, tree] {
    match $platform {
        'U60' => { create_config 'Glacier' $tree 'HpWintersWks' 'MultiProject/U60Glacier/BLD/BiosId.env' }
        'U61' => { create_config 'Winters' $tree 'HpWintersWks' 'MultiProject/U61Blizzard/BLD/BiosId.env' }
        'U65' => { create_config 'Avalanche' $tree 'HpAvalancheWks' 'BLD/RSPS/BiosId.env' }
        'X60' | null => { create_config 'Springs' $tree 'HpSpringsWks' 'MultiProject/X60Steamboat/BLD/BiosId.env' } # Use Springs config by default
        _ => {
            error make {
                msg: "Unknown platform"
                label: {
                    text: "Platform not recognized"
                    span: (metadata $platform).span
                }
            }
        }
    }
}

def set_version [file version?] {
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
    print $"(ansi yellow)Setting feature version ($curr_version | into string | ansi apply {fg: "#808080"}) → ($new_version | into string | ansi apply blue)(ansi reset)"
    let new_contents = open $file | lines | each {|e|
        if ($e | str contains VERSION_FEATURE) {
            $e | str replace $curr_version_str ($new_version | format hex -r)
        } else { $e }
    } | str join "\n"
    $new_contents + "\n" | save -f $file
}

def build [config, release] {
    # print $"(ansi purple)Building binary...(ansi reset)"
    cd $config.pltpkg_loc
    let command = match $config.name {
        'Glacier' => 'HpBldGlacier.bat'
        "Winters" => 'HpBldBlizzard.bat'
        "Avalanche" => 'HpBiosBuild.bat'
        "Springs" | null => 'HpBldSprings.bat'
    }
    try {
        if $release {
            print $"(ansi purple)Building RELEASE binary...(ansi reset)"
            run-external $command 'r'
        } else {
            print $"(ansi purple)Building DEBUG binary...(ansi reset)"
            run-external $command
        }
    } catch {
        # print $"\n\n(ansi red)Build failed(ansi reset)"
        "Build failed" | splash failure
        error make -u {msg: "Build failed"}
    }
    cd -
}

def save_bootleg [bootleg_loc, binary_path, append?: string] {
    let bootleg_basename = match $append {
        null => ($binary_path | path basename)
        _ => {
            let parsed = $binary_path | path parse
            $parsed.stem + '_' + $append + '.' + $parsed.extension
        }
    }
    let bootleg_path = [$bootleg_loc, $bootleg_basename] | path join
    cp $binary_path $bootleg_path
    print -n $"Saved bootleg (ansi blue)($bootleg_basename)(ansi reset) to "
}

def get_binary [path] {
    try {
        ls ($path | path expand) | where name =~ '^(?i)(?!.*pvt).*?(32|64).*\.bin$' | sort-by modified | last
    } catch {
        null
    }
}

def print_info [binary] {
    print $"(ansi blue)($binary.name | path basename)(ansi reset)"
    print $"Size: ($binary.size | format filesize MiB)"
}

def find_build [bld_path] {
    let binary = get_binary $bld_path
    if $binary != null {
        print -n $"Found binary in build folder: "
        print_info $binary
    }
    $binary
}

def find_bootleg [bootleg_loc] {
    let binary = get_binary $bootleg_loc
    if $binary != null {
        print -n $"Found binary in bootlegs folder: "
        print_info $binary
    }
    $binary
}

def find_path [path] {
    let binary = get_binary $path
    if $binary != null {
        print -n $"Found specified binary: "
        print_info $binary
    }
    $binary
}

def flash [binary] {
    print $"(ansi purple)Flashing binary...(ansi reset)"
    try {
        do {dpcmd --batch $binary.name --verify}
        print $"\n(ansi green_bold)Flash successful(ansi reset)"
        # "Flash successful"| blink | splash green -s 3
    } catch {|err|
        print $err.rendered
        error make -u { msg: "Flash failed" }
        # "Flash failed" | blink | splash red -s 3
    }
}

# Build, save, and flash a bootleg binary
#
# Example: Test
export def main [
    platform?: string
    --build(-b)               # Build the binary
    --release(-r)             # Build a release binary
    --bootleg(-l)             # Use the latest bootleg binary
    --save(-s)                # Save the build to the bootlegs folder
    --network(-n)             # Save the bootleg to the network drive
    --flash(-f)               # Flash the binary using DediProg
    --tree(-t): string        # Specify a specific tree to use
    --path(-p): string        # Manually specify a filepath for a binary to flash
    --append(-a): string      # Append a string to the bootleg basename
    --no-decrement(-d)        # Don't decrement the feature number
    --set-version(-v): int    # Set the feature version number directly
] {
    let config = get_config $platform $tree
    print $"Using config for (ansi blue)($config.name)(ansi reset) with tree ($config.repo_loc | path basename)"
    let binary = if $build {
        if $set_version != null {
            set_version $config.biosid_loc $set_version
        } else if not $no_decrement {
            set_version $config.biosid_loc
        }
        build $config $release
        find_build $config.bld_path
    } else if $bootleg {
        find_bootleg $config.bootleg_loc
    } else if $path != null {
        find_path $path
    } else {
        print $"(ansi yellow)Warning:(ansi reset) No binary provided → Checking build folder...(ansi reset)"
        find_build $config.bld_path
    }
    if $binary == null {
        # print -e $"(ansi red_bold)No binary found(ansi reset)"
        error make -u { msg: "No binary found" }
    }
    if $save {
        save_bootleg $config.bootleg_loc $binary.name $append
        print "local bootlegs folder"
    }
    if $network {
        save_bootleg $config.network_loc $binary.name $append
        print "network bootlegs folder"
    }
    if $flash {
        flash $binary
    } else {
        print $"(ansi yellow)Skipped flash(ansi reset)"
    }
}
