# ---------------------------------------------------------------------------- #
#                                bios-utils.nu                                 #
# ---------------------------------------------------------------------------- #

use ../modules/rest.nu ['path stem-append']

const NETWORK_BOOTLEGS_PATH = '\\wks-file.ftc.rd.hpicorp.net\MAIN_LAB\SHARES\LAB\Brendon Felix\Bootlegs'

export def --env `bios set-project` [project: string] {
    $env.CURR_PROJECT = fetch_project $project
}

# ---------------------------------------------------------------------------- #

def fetch_project [project?: string]: nothing -> record {
    match $project {
        null => $env.CURR_PROJECT
        $p => {
            let result = $env.BIOS_PROJECTS | find -n $p | first
            if $result == null {
                error make {
                    msg: "project not found",
                    label: { text: "no matching project", span: (metadata $project).span }
                }
            }
            $result
        }
    }
}

def fetch_binary [path: string] {
    let matches = ls $path | where name =~ '^(?i)(?!.*pvt).*?(32|64).*\.bin$'
    match ($matches | length) {
        0 => {
            error make {
                msg: "no binaries found",
                label: { text: "no matching binaries at path", span: (metadata $path).span }
            }
        }
        _ => ($matches | sort-by -r modified | first)
    }
}

def find_build [project: record]: nothing -> record {
    let build_path = $project.top_level | path join 'HpPlatformPkg' 'BLD' 'FV'
    fetch_binary $build_path
}

def find_bootleg [project: record]: nothing -> record {
    let bootleg_path = '~\BIOS\Bootlegs' | path join $project.name
    fetch_binary $bootleg_path
}

# ---------------------------------------------------------------------------- #

export def `bios build` [
    --project(-p): string
    --release(-r)
    --set-version(-v): int
] {
    let project = fetch_project $project
    cd $project.top_level
    match $release {
        true => (run-external $project.build_script 'r')
        false => (run-external $project.build_script)
    }
}

export def `bios save` [
    --project(-p): string
    --append(-a): string
] {
    let project = fetch_project $project
    let binary = find_build $project
    let basename = match $append {
        null => ($binary.name | path basename)
        $s => ($binary.name | path basename | path stem-append $s)
    }
    let save_path = '~\BIOS\Bootlegs' | path join $project.name $basename
    cp $binary.name $save_path
}

export def `bios upload` [
    --project(-p): string
    --append(-a): string
    --bootleg(-l)
] {
    let project = fetch_project $project
    let binary = match $bootleg {
        true => (find_bootleg $project)
        false => (find_build $project)
    }
    let basename = match $append {
        null => ($binary.name | path basename)
        $s => ($binary.name | path basename | path stem-append $s)
    }
    let save_path = $NETWORK_BOOTLEGS_PATH | path join $project.name $basename
    cp $binary.name $save_path
}

export def `bios flash` [
    --project(-p): string
    --path(-p): string
    --bootleg(-l)
] {
    let project = fetch_project $project
    let binary = {
        match $path {
            null => {
                match $bootleg {
                    true => (find_bootleg $project)
                    false => (find_build $project)
                }
            }
            $p => (fetch_binary $p)
        }
    }
    dpcmd --batch --verify $binary.name
}

# export def `bios siofw` [
#     --signature(-s)
#     --debug(-d)
# ] {

# }
