# ---------------------------------------------------------------------------- #
#                                   epsc.nu                                    #
# ---------------------------------------------------------------------------- #

use ../modules/path.nu 'path slice'
use ../modules/procedure.nu *

const target_path = 'C:\Users\felixb\BIOS\HpSpringsWks\'
const source_path = 'C:\Users\felixb\BIOS\HpEpsc\HpNuvoton324Pkg\Include'

def pull_source [] {
    print $"Pulling latest source from HpEpsc repository..."
}

# Update the SIO FW version
export def main [--regs(-r)] {
    procedure run -d "HpEpsc SIO Firmware Update" {

        procedure new-task 'Pulling HpEpsc source' {
            cd $source_path
            git pull
        }

        mut updates = [
            {
                source: 'HpSioDev\HpSioFireBirdFwVersion.equ'
                targets: [
                    'HpEpsc\HpNuvoton324Pkg\Include\HpSioDev\HpSioFireBirdFwVersion.equ'
                    'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSioDev\HpSioFireBirdFwVersion.equ'
                ]
            }
            {
                source: 'HpSioDev\HpSuperIoFw.bin'
                targets: [
                    'HpEpsc\HpNuvoton324Pkg\Include\HpSioDev\HpSuperIoFw.bin'
                    'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSioDev\HpSuperIoFw.bin'
                ]
            }
            {
                source: 'HpSioFireBirdFwVersion.equ'
                targets: [
                    'HpEpsc\HpNuvoton324Pkg\Include\HpSioFireBirdFwVersion.equ'
                    'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSioFireBirdFwVersion.equ'
                ]
            }
            {
                source: 'HpSuperIoFw.bin'
                targets: [
                    'HpEpsc\HpNuvoton324Pkg\Include\HpSuperIoFw.bin'
                    'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSuperIoFw.bin'
                ]
            }
            {
                source: 'HpSuperIoFw.sig'
                targets: [
                    'HpEpsc\HpNuvoton324Pkg\Include\HpSuperIoFw.sig'
                    'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSuperIoFw.sig'
                ]
            }
            {
                source: 'HpSuperIoFw.bin.hpsign'
                targets: [
                    'HpEpsc\HpNuvoton324Pkg\Include\HpSuperIoFw.bin.hpsign'
                    'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSuperIoFw.bin.hpsign'
                ]
            }
        ]

        if $regs {
            $updates = $updates | append [
                {
                    source: 'HpSioRegs.equ'
                    targets: [
                        'HpEpsc\HpNuvoton324Pkg\Include\HpSioRegs.equ'
                    ]
                }
                {
                    source: 'HpSioRegs.h'
                    targets: [
                        'HpEpsc\HpNuvoton324Pkg\Include\HpSioRegs.h'
                    ]
                }
            ]
        }

        for update in $updates {
            let source_file = $source_path | path join $update.source
            $env.PROCEDCURE_DEBUG = true
            procedure new-task $"Copying (ansi blue)($update.source)(ansi reset)" {
                for $target in $update.targets {
                    let target_file = $target_path | path join $target
                    procedure new-task -c $"($target_file | path slice (-4)..(-2) | fill -w 32)" {
                        cp $source_file $target_file
                    }
                }
            }
        }
    }
}
