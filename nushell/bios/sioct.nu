
use std assert

const SIOCT_PATH: path = '~\BIOS\HpSpringsWks\HpPlatformPkg\SioConfigurationTable\Sioct.csv' | path expand

def "nu-complete sioct registers" [] {
    let sioct = open $SIOCT_PATH
    $sioct | get RegName | uniq | sort
}

def int_to_sio_hex [value: int] {
    if ($value > 255) or ($value < 0) {
        error make -u {msg: "Value out of range (0x0-0xFF)"}
    }
    let result = '0' + ($value | format hex --remove-prefix --width 2) + 'h'
    assert (($result | str length) == 4)
    $result
}

def modify_entry_values [entry, new_value: int] {
    let hex_value = int_to_sio_hex $new_value
    print $"Using new value: ($hex_value | paint yellow)"
    $entry | update cells -c [PRJ1 PRJ2 PRJ3 PRJ4 PRJ5 PRJ6] { $hex_value }
}

def display_entry [entry] {
    print ($entry | select RstPwr RegType RegName DFLT MASK PRJ1 PRJ2 PRJ3 PRJ4 PRJ5 PRJ6)
}

export def main [
    register?: string@"nu-complete sioct registers"
] {
    let sioct = open $SIOCT_PATH
    if $register != null {
        let matches = $sioct | enumerate | where item.RegName == $register
        let match = match ($matches | length) {
            0 => { error make -u {msg: "No matching entry found in SIOCT"} }
            1 => ($matches | first)
            _ => {
                print "Matching entries:" ($matches | get item)
                error make -u {msg: "Multiple matching entries found in SIOCT"}
            }
        }
        display_entry $match.item
    } else {
        $sioct | select RstPwr RegType RegName DFLT MASK PRJ1 PRJ2 PRJ3 PRJ4 PRJ5 PRJ6
    }
}

export def `sioct edit` [
    register: string@"nu-complete sioct registers"
    new_value: int
] {
    mut sioct = open $SIOCT_PATH
    let matches = $sioct | enumerate | where item.RegName == $register
    let match = match ($matches | length) {
        0 => { error make -u {msg: "No matching entry found in SIOCT"} }
        1 => ($matches | first)
        _ => {
            print "Matching entries:" ($matches | get item)
            error make -u {msg: "Multiple matching entries found in SIOCT"}
        }
    }
    let idx = $match.index
    let entry = $match.item
    print "Modifying entry:"
    display_entry $entry
    let modified_entry = modify_entry_values $entry $new_value
    display_entry $modified_entry
    $sioct = $sioct | update $idx $modified_entry
    mut csv = $sioct | to csv
    $csv = $csv | str replace --all -r '.[\n]' ",,\r\n"
    $csv = $csv | str replace --all ",\n" ",,\r\n"
    $csv | save -f $SIOCT_PATH
}
