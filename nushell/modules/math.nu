

export def `interpolate` [
    end: number
    t: float
]: [
    int -> int
    float -> float
    list<int> -> list<int>
    list<float> -> list<float>
] {
    let $start = $in
    if ($end | describe) != ($start | describe) {
        error make {
            msg: "type mismatch"
            label: {
                text: "start and end must be of the same type"
                span: (metadata $end).span
            }
        }
    }
    if $t < 0.0 or $t > 1.0 {
        error make {
            msg: "invalid value"
            label: {
                text: "t must be between 0.0 and 1.0"
                span: (metadata $t).span
            }
        }
    }

    match $start {
        $s if ($s | describe) == "int" => ($start + (($end - $start) * $t) | math round)
        $s if ($s | describe) == "float" => ($start + (($end - $start) * $t))
        $s if ($s | describe) == "list<int>" => ($start | zip $end | each {|e|
            let s = $e.0
            let e = $e.1
            ($s + (($e - $s) * $t) | math round)
        })
        $s if ($s | describe) == "list<float>" => ($start | zip $end | each {|e|
            let s = $e.0
            let e = $e.1
            ($s + (($e - $s) * $t))
        })
    }
}

export def `interpolate-modulus` [
    end: number,
    modulus: number,
    t: number,
]: [
    int -> int
    float -> float
    list<int> -> list<int>
    list<float> -> list<float>
] {
    let start = $in
    if ($end | describe) != ($start | describe) {
        error make {
            msg: "type mismatch"
            label: {
                text: "start and end must be of the same type"
                span: (metadata $end).span
            }
        }
    }
    if $t < 0.0 or $t > 1.0 {
        error make {
            msg: "invalid value"
            label: {
                text: "t must be between 0.0 and 1.0"
                span: (metadata $t).span
            }
        }
    }

    match $start {
        $s if ($s | describe) == "int" => {
            let delta = ($end - $start) mod $modulus
            let delta = if $delta > ($modulus / 2) { $delta - $modulus } else { $delta }
            ($start + ($delta * $t) | math round) mod $modulus
        }
        $s if ($s | describe) == "float" => {
            let delta = ($end - $start) mod $modulus
            let delta = if $delta > ($modulus / 2) { $delta - $modulus } else { $delta }
            ($start + ($delta * $t)) mod $modulus
        }

    }
}
