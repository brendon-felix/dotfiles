const UPDATE_INTERVAL = 200ms

export def memory_str [] {
    let memory = (sys mem)
    let proportion_used = $memory.used / $memory.total
    let percent_used = ($proportion_used * 100 | math round --precision 0 )
    let memory_bar = (asciibar --empty '░' --half-filled '▓' --filled '█' --length 12 $proportion_used)
    let memory_text = $"($memory.used) \(($percent_used)%\)"
    match $proportion_used {
        _ if $proportion_used < 0.6 => {
            text: $"(ansi green)($memory_text)(ansi reset)"
            bar: $"(ansi green)($memory_bar)(ansi reset)"
        }
        _ if $proportion_used < 0.8 => {
            text: $"(ansi yellow)($memory_text)(ansi reset)"
            bar: $"(ansi yellow)($memory_bar)(ansi reset)"
        }
        _ => {
            text: $"(ansi red)($memory_text)(ansi reset)"
            bar: $"(ansi red)($memory_bar)(ansi reset)"
        }
    }
}

export def "memory monitor" [] {
    clear
    # let loading = ["|", "/", "-", "\\"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
    # let loading = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
    let loading = ["⠋", "⠙", "⠸", "⠴", "⠦", "⠇"] | each { |it| $"(ansi cyan)($it)(ansi reset)" }
    loop {
        let memory = memory_str
        for e in $loading {
            print -n $"RAM: ($memory.bar) ($memory.text) ($e)\r"
            sleep $UPDATE_INTERVAL
        }
    }
}

export def main [] {
    let memory = memory_str
    print -n $"RAM: ($memory.bar) ($memory.text)"
}