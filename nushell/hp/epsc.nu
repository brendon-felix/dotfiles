# ---------------------------------------------------------------------------- #
#                                   epsc.nu                                    #
# ---------------------------------------------------------------------------- #

use ../modules/path.nu 'path slice'
use ../modules/procedure.nu *

const springs_target_path = 'C:\Users\felixb\BIOS\HpSpringsWks\'
const springs_source_path = 'C:\Users\felixb\BIOS\HpEpsc\HpNuvoton324Pkg\Include'

def pull_source [] {
    print $"Pulling latest source from HpEpsc repository..."
}

# Update the SIO FW version
export def `epsc springs` [--regs(-r)] {
    procedure run -d "HpEpsc SIO Firmware Update" {

        procedure new-task 'Pulling HpEpsc source' {
            cd $springs_source_path
            git switch main
            git pull
        }

        mut updates = [
            {
                # source: 'HpSioDev\HpSioFireBirdFwVersion.equ'
                source: 'HpSioFireBirdFwVersion.equ'
                targets: [
                    'HpEpsc\HpNuvoton324Pkg\Include\HpSioDev\HpSioFireBirdFwVersion.equ'
                    'HpPlatformPkg\MultiProject\X60Steamboat\SIOFW\HpSioDev\HpSioFireBirdFwVersion.equ'
                ]
            }
            {
                # source: 'HpSioDev\HpSuperIoFw.bin'
                source: 'HpSuperIoFw.bin'
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
            let source_file = $springs_source_path | path join $update.source
            $env.PROCEDCURE_DEBUG = true
            procedure new-task $"Copying (ansi blue)($update.source)(ansi reset)" {
                for $target in $update.targets {
                    let target_file = $springs_target_path | path join $target
                    procedure new-task -c $"($target_file | path slice (-4)..(-2) | fill -w 32)" {
                        cp $source_file $target_file
                    }
                }
            }
        }
    }
}



const winters_target_path = 'C:\Users\felixb\BIOS\HpWintersWks'
const winters_working_path = 'C:\Users\felixb\BIOS\HpEpsc'
const winters_source_path = 'C:\Users\felixb\BIOS\HpEpsc\HpNuvoton321Pkg\Include'

export def `epsc winters` [--regs(-r)] {
    procedure run -d "HpEpsc SIO Firmware Update" {

        procedure new-task 'Pulling HpEpsc source' {
            cd $winters_working_path
            git switch 2022/main
            git pull
        }

        mut updates = [
            {
                source: 'HpSioDev\HpSioFireBirdFwVersion.equ'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSioDev\HpSioFireBirdFwVersion.equ'
                    'HpPlatformPkg\MultiProject\U60Glacier\SIOFW\HpSioDev\HpSioFireBirdFwVersion.equ'
                    'HpPlatformPkg\MultiProject\U61Blizzard\SIOFW\HpSioDev\HpSioFireBirdFwVersion.equ'
                    'HpPlatformPkg\MultiProject\U62Ice\SIOFW\HpSioDev\HpSioFireBirdFwVersion.equ'
                ]
            }
            {
                source: 'HpSioDev\HpSuperIoFw.bin'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSioDev\HpSuperIoFw.bin'
                    'HpPlatformPkg\MultiProject\U60Glacier\SIOFW\HpSioDev\HpSuperIoFw.bin'
                    'HpPlatformPkg\MultiProject\U61Blizzard\SIOFW\HpSioDev\HpSuperIoFw.bin'
                    'HpPlatformPkg\MultiProject\U62Ice\SIOFW\HpSioDev\HpSuperIoFw.bin'
                ]
            }
            {
                source: 'HpSioFireBirdFwVersion.equ'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSioFireBirdFwVersion.equ'
                    'HpPlatformPkg\MultiProject\U60Glacier\SIOFW\HpSioFireBirdFwVersion.equ'
                    'HpPlatformPkg\MultiProject\U61Blizzard\SIOFW\HpSioFireBirdFwVersion.equ'
                    'HpPlatformPkg\MultiProject\U62Ice\SIOFW\HpSioFireBirdFwVersion.equ'
                ]
            }
            {
                source: 'HpSuperIoFw.bin'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSuperIoFw.bin'
                    'HpPlatformPkg\MultiProject\U60Glacier\SIOFW\HpSuperIoFw.bin'
                    'HpPlatformPkg\MultiProject\U61Blizzard\SIOFW\HpSuperIoFw.bin'
                    'HpPlatformPkg\MultiProject\U62Ice\SIOFW\HpSuperIoFw.bin'
                ]
            }
            {
                source: 'HpSuperIoFw.sig'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSuperIoFw.sig'
                    'HpPlatformPkg\MultiProject\U60Glacier\SIOFW\HpSuperIoFw.sig'
                    'HpPlatformPkg\MultiProject\U61Blizzard\SIOFW\HpSuperIoFw.sig'
                    'HpPlatformPkg\MultiProject\U62Ice\SIOFW\HpSuperIoFw.sig'
                ]
            }
            {
                source: 'HpSuperIoFw.bin.hpsign'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSuperIoFw.bin.hpsign'
                    'HpPlatformPkg\MultiProject\U60Glacier\SIOFW\HpSuperIoFw.bin.hpsign'
                    'HpPlatformPkg\MultiProject\U61Blizzard\SIOFW\HpSuperIoFw.bin.hpsign'
                    'HpPlatformPkg\MultiProject\U62Ice\SIOFW\HpSuperIoFw.bin.hpsign'
                ]
            }
        ]

        if $regs {
            # $updates = $updates | append [
            #     {
            #         source: 'HpSioRegs.equ'
            #         targets: [
            #             'HpEpsc\HpNuvoton324Pkg\Include\HpSioRegs.equ'
            #         ]
            #     }
            #     {
            #         source: 'HpSioRegs.h'
            #         targets: [
            #             'HpEpsc\HpNuvoton324Pkg\Include\HpSioRegs.h'
            #         ]
            #     }
            # ]
            
            print "NOT SUPPORTED YET"
        }

        for update in $updates {
            let source_file = $winters_source_path | path join $update.source
            $env.PROCEDCURE_DEBUG = true
            procedure new-task $"Copying (ansi blue)($update.source)(ansi reset)" {
                for $target in $update.targets {
                    let target_file = $winters_target_path | path join $target
                    procedure new-task -c $"($target_file | path slice (-4)..(-2) | fill -w 32)" {
                        cp $source_file $target_file
                    }
                }
            }
        }
    }
}

const avalanche_target_path = 'C:\Users\felixb\BIOS\HpAvalancheWks'
const avalanche_working_path = 'C:\Users\felixb\BIOS\HpEpsc'
const avalanche_source_path = 'C:\Users\felixb\BIOS\HpEpsc\HpNuvoton321Pkg\Include'

export def `epsc avalanche` [--regs(-r)] {
    procedure run -d "HpEpsc SIO Firmware Update" {

        procedure new-task 'Pulling HpEpsc source' {
            cd $avalanche_working_path
            git switch 2022/main
            git pull
        }

        mut updates = [
            {
                source: 'HpSioDev\HpSioFireBirdFwVersion.equ'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSioDev\HpSioFireBirdFwVersion.equ'
                ]
            }
            {
                source: 'HpSioDev\HpSuperIoFw.bin'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSioDev\HpSuperIoFw.bin'
                ]
            }
            {
                source: 'HpSioFireBirdFwVersion.equ'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSioFireBirdFwVersion.equ'
                ]
            }
            {
                source: 'HpSuperIoFw.bin'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSuperIoFw.bin'
                ]
            }
            {
                source: 'HpSuperIoFw.sig'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSuperIoFw.sig'
                ]
            }
            {
                source: 'HpSuperIoFw.bin.hpsign'
                targets: [
                    'HpEpsc\HpNuvoton321Pkg\Include\HpSuperIoFw.bin.hpsign'
                ]
            }
        ]

        if $regs {
            # $updates = $updates | append [
            #     {
            #         source: 'HpSioRegs.equ'
            #         targets: [
            #             'HpEpsc\HpNuvoton324Pkg\Include\HpSioRegs.equ'
            #         ]
            #     }
            #     {
            #         source: 'HpSioRegs.h'
            #         targets: [
            #             'HpEpsc\HpNuvoton324Pkg\Include\HpSioRegs.h'
            #         ]
            #     }
            # ]
            
            print "NOT SUPPORTED YET"
        }

        for update in $updates {
            let source_file = $avalanche_source_path | path join $update.source
            $env.PROCEDCURE_DEBUG = true
            procedure new-task $"Copying (ansi blue)($update.source)(ansi reset)" {
                for $target in $update.targets {
                    let target_file = $avalanche_target_path | path join $target
                    procedure new-task -c $"($target_file | path slice (-4)..(-2) | fill -w 32)" {
                        cp $source_file $target_file
                    }
                }
            }
        }
    }
}
