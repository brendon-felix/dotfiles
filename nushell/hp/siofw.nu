# ---------------------------------------------------------------------------- #
#                                   siofw.nu                                   #
# ---------------------------------------------------------------------------- #

use ../modules/procedure.nu *

const repo_path = 'C:\Users\felixb\BIOS\HpSpringsWks\'

def get_ver [file] {
    let val = $file | parse -r '(?P<version>[a-fA-F0-9]{7})h' | first | get version
    $val | parse -r '0(?P<maj>[a-fA-F0-9]{2})(?P<min>[a-fA-F0-9]{2})(?P<feat>[a-fA-F0-9]{2})'
        | into int min feat | into string maj min feat | first | values | str join '.'
    # $val | parse -r '0(?P<maj>[a-fA-F0-9]{2}){3}'
}

def make_equ_str [version] {
    let v = $version | split row '.'
        | each { |it| $it | fill -a r -c '0' -w 2 } | str join
    ['0', $v] | str join
}

def update_equ [filepath, version] {
    mut equ_file = open $filepath
    let equ_str = make_equ_str $version
    let curr_ver = get_ver $equ_file
    print $"Changing from (ansi grey)v($curr_ver)(ansi reset) to (ansi yellow)v($version)(ansi reset)"
    ($equ_file | str replace -r '[a-fA-F0-9]{7}h' $'($equ_str)h') | save -f $filepath
    print $"(ansi green)Successfully updated(ansi reset) ($filepath | path basename)"
}

# Update the SIO FW version
export def `siofw springs` [
    version,
    --all(-a) # Update all binary and .equ files in the repo
    --sig(-s) # Update the signature files
    ] {
    # let equ_filename = 'C:\Users\felixb\BIOS\HpSpringsWks\HpEpsc\HpNuvoton324Pkg\Include\HpSioDev\HpSioFireBirdFwVersion.equ'
    # [
    #    {
    #        basename: 'HpSioFireBirdFwVersion.equ'
    #    }
    # ]
    let equ_filename1 = [$repo_path, 'HpEpsc\HpNuvoton324Pkg\Include\HpSioDev\HpSioFireBirdFwVersion.equ'] | path join
    let equ_filename2 = [$repo_path, 'HpEpsc\HpNuvoton324Pkg\Include\HpSioFireBirdFwVersion.equ'] | path join
    let equ_filename3 = [$repo_path, 'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSioDev\HpSioFireBirdFwVersion.equ'] | path join
    let equ_filename4 = [$repo_path, 'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSioFireBirdFwVersion.equ'] | path join

    let bin_filename1 = [$repo_path, 'HpEpsc\HpNuvoton324Pkg\Include\HpSioDev\HpSuperIoFw.bin'] | path join
    let bin_filename2 = [$repo_path, 'HpEpsc\HpNuvoton324Pkg\Include\HpSuperIoFw.bin'] | path join
    let bin_filename3 = [$repo_path, 'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSioDev\HpSuperIoFw.bin'] | path join
    let bin_filename4 = [$repo_path, 'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSuperIoFw.bin'] | path join

    let sig_filename1 = [$repo_path, 'HpEpsc\HpNuvoton324Pkg\Include\HpSuperIoFw.sig'] | path join
    let sig_filename2 = [$repo_path, 'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSuperIoFw.sig'] | path join




    let new_bin = try {
        (ls ($'~\Downloads\*($version)*.bin' | into glob) | sort-by modified | last)
    } catch {
        print $"(ansi red)Could not find binary file matching ($version)(ansi reset)"
        exit 1
    }
    print $"Found binary (ansi blue)($new_bin.name | path basename)(ansi reset)"

    update_equ $equ_filename1 $version
    print $"Copying new binary to HpEpsc HpSioDev..."
    try {
        cp $new_bin.name $bin_filename1
    } catch {
        print $"(ansi red)Failed copying(ansi reset) ($new_bin.name | path basename)"
        exit 1
    }


    if $all {
        update_equ $equ_filename2 $version
        print $"Copying new binary to HpEpsc..."
        try {
            cp $new_bin.name $bin_filename2
        } catch {
            print $"(ansi red)Failed copying(ansi reset) ($new_bin.name | path basename)"
            exit 1
        }
        update_equ $equ_filename3 $version
        print $"Copying new binary to HpPlatformPkg HpSioDev..."
        try {
            cp $new_bin.name $bin_filename3
        } catch {
            print $"(ansi red)Failed copying(ansi reset) ($new_bin.name | path basename)"
            exit 1
        }
        update_equ $equ_filename4 $version
        print $"Copying new binary to HpPlatformPkg..."
        try {
            cp $new_bin.name $bin_filename4
        } catch {
            print $"(ansi red)Failed copying(ansi reset) ($new_bin.name | path basename)"
            exit 1
        }
    }



    if $sig {
        let new_sig = try {
            (ls ($'~\Downloads\*($version)*.sig' | into glob) | sort-by modified | last)
        } catch {
            print $"(ansi red)Could not find signature file matching ($version)(ansi reset)"
            exit 1
        }
        print $"Found signature (ansi blue)($new_sig.name | path basename)(ansi reset)"

        print $"Copying new signature to HpEpsc..."
        try {
            cp $new_sig.name $sig_filename1
        } catch {
            print $"(ansi red)Failed copying(ansi reset) ($new_bin.name | path basename)"
            exit 1
        }

        print $"Copying new signature to HpPlatformPkg..."
        try {
            cp $new_sig.name $sig_filename2
        } catch {
            print $"(ansi red)Failed copying(ansi reset) ($new_bin.name | path basename)"
            exit 1
        }
    }

    # print $"(ansi green)Successfully copied(ansi reset) ($new_bin.name | path basename) to HpEpsc"
    print $"(ansi green)Successfully updated SIO FW(ansi reset)"
    #
    # cp (ls ($'~/Downloads/*($version)*.bin' | into glob) | sort-by modified | last).name HpSuperIoFw.bin
}

# export def main [
#     version: string
#     platform: string = 'springs'
#     --siodev(-d)
#     --signature(-s)
# ] {
#     let paths = match $platform {
#         'springs' => [
#             '~/BIOS/HpSpringsWks/HpEpsc/HpNuvoton324Pkg/Include'
#             '~/BIOS/HpSpringsWks/HpPlatformPkg/MultiProject/X60Steamboat/SIOFW'
#         ]
#         'winters' => [
#             '~/BIOS/HpWintersWks/HpEpsc/HpNuvoton321Pkg/Include'
#             '~/BIOS/HpWintersWks/HpPlatformPkg/MultiProject/U60Glacier/SIOFW'
#             '~/BIOS/HpWintersWks/HpPlatformPkg/MultiProject/U61Blizzard/SIOFW'
#             '~/BIOS/HpWintersWks/HpPlatformPkg/MultiProject/U62Ice/SIOFW'
#         ]
#     } | path expand
#     procedure run "Copying SIOFW" {
#         let new_bin = procedure new-task 'Fetching binary from Downloads' {
#             let new_bin = try {
#                 (ls ($'~\Downloads\*($version)*.bin' | into glob) | sort-by modified | last)
#             } catch {
#                 error make -u { msg: $"Could not find binary file matching ($version)" }
#             }
#             procedure print $"Found binary (ansi blue)($new_bin.name | path basename)(ansi reset)"
#             $new_bin
#         }
#         for path in $paths {
#         }
#     }
# }
