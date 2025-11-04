export use bfm2.nu *
export use epsc.nu *
export use siofw.nu *

export-env {
    $env.BIOS_CONFIGS = {
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
}
