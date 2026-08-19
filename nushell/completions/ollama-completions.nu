
export extern ollama [
]

def "nu-complete think" [] {
    ['true' 'false' high medium low]
}

def "nu-complete bool" [] {
    ['true' 'false']
}

export extern `ollama run` [
    --dimensions: int
    --experimental
    --experimental-websearch
    --experimental-yolo
    --format: string
    --hidethinking
    --insecure
    --keepalive: duration
    --nowordwrap
    --think: string@"nu-complete think"
    --truncate: string@"nu-complete bool"
    --verbose
]
