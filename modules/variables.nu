# ---------------------------------------------------------------------------- #
#                                 variables.nu                                 #
# ---------------------------------------------------------------------------- #

export def `var update` [new_values?: record = {}] {
    touch $env.VARS_FILE
    let vars = open $env.VARS_FILE
    let updated = $vars | merge $new_values
    $updated | to toml | save -f $env.VARS_FILE
}

export def `var save` [name: string] {
    let value = $in
    touch $env.VARS_FILE
    let vars = open $env.VARS_FILE
    let updated = $vars | upsert $name $value
    $updated | to toml | save -f $env.VARS_FILE
}

export def `var load` [name?: string] {
    if not ($env.VARS_FILE | path exists) {
        error make {
            msg: "vars file does not exist"
            label: {
                text: "create a vars file first with `var update`"
                span: (metadata $env.VARS_FILE).span
            }
        }
    }
    let vars = open $env.VARS_FILE
    if $name != null {
        $vars | get -i $name
    } else {
        $vars
    }
}

export def `var delete` [name: string] {
    if not ($env.VARS_FILE | path exists) {
        error make {
            msg: "vars file does not exist"
            label: {
                text: "create a vars file first with `var update`"
                span: (metadata $env.VARS_FILE).span
            }
        }
    }
    let vars = open $env.VARS_FILE
    $vars | reject $name | to toml | save -f $env.VARS_FILE
}
