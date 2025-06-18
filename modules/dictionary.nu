# ---------------------------------------------------------------------------- #
#                                 dictionary.nu                                #
# ---------------------------------------------------------------------------- #

export def define [$phrase] {
    let result = td def $phrase | lines
    let type = $result | parse '{_}-----------{type}' | get type | str downcase
    $type
}

export def synonyms [$phrase] {
    td thes $phrase
}

export def antonyms [$phrase] {
    td thes $phrase
}
