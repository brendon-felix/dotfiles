
export def `commands built-in` [] {
    commands| where command_type == built-in | select name description
}

export def `commands external` [] {
    commands | where command_type == external | select name description
}

export def `commands custom` [] {
    commands| where command_type == custom | select name description
}

export def aliases [] {
    commands | where command_type == alias | select name description
}

export def "commands plugin" [] {
    commands | where command_type == plugin | select name description
}

export def commands [] {
    help commands | reject params input_output search_terms is_const
}


