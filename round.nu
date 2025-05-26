

def "round duration" [unit?] {
    each { |e|
        let num_ns = $e | into int
        let unit_ns = match $unit {
            ns => (1ns | into int),
            us => (1us | into int),
            ms => (1ms | into int),
            sec => (1sec | into int),
            min => (1min | into int),
            hr => (1hr | into int),
            day => (1day | into int),
            wk => (1wk | into int),
            _ => (return (auto_round_duration $num_ns)), # If the unit is not recognized, return the original duration
        }
        let rounded_ns = ($num_ns / $unit_ns | math round) * $unit_ns
        $rounded_ns | into duration
    }
}

def auto_round_duration [num_ns] {
    
}