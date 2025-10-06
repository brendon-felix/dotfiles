
# ---------------------------------------------------------------------------- #
#                                 variables.nu                                 #
# ---------------------------------------------------------------------------- #

const VARS_FILE = $nu.data-dir | path join "vars.toml"

def check_vars_file [] {
    if not ($VARS_FILE | path exists) {
        error make {
            msg: "vars file does not exist"
            label: {
                text: "create a vars file first with `var update`"
                span: (metadata $VARS_FILE).span
            }
        }
    }
}

export def `var update` [new_values?: record = {}] {
    check_vars_file
    let vars = open $VARS_FILE
    let updated = $vars | merge $new_values
    $updated | to toml | save -f $VARS_FILE
}

export def `var save` [name: string] {
    check_vars_file
    let value = $in
    let vars = open $VARS_FILE
    let updated = $vars | upsert $name $value
    $updated | to toml | save -f $VARS_FILE
}

export def `var load` [name?: string] {
    check_vars_file
    let vars = open $VARS_FILE
    if $name != null {
        $vars | get -o $name
    } else {
        $vars
    }
}

export def `var delete` [name: string] {
    check_vars_file
    let vars = open $VARS_FILE
    $vars | reject $name | to toml | save -f $env.VARS_FILE
}
