

export alias syncthing = start http://localhost:57510

export def `fermi gpu-temp` [] {
    let value = ssh fermi "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits" | into int
    print $"($value)°C"
}

export def `syncthing fermi` [] {
    let ip = $env.HOSTS | where hostname == fermi | first | get tail_ip
    job spawn {
        ssh -L 2200:localhost:2200 felixb@($ip) "nu -c 'loop {}'"
    }
    start http://localhost:8384
}

export def `postgres fermi` [] {
    let ip = $env.HOSTS | where hostname == fermi | first | get tail_ip
    psql -h ($ip) -U
}

export def `subroutine get-data` [] {
    http get $"($env.SUBROUTINE_SERVER)/v1/data"
}

def uuid_now_v7 []: nothing -> string {
    random uuid -v 7
}

export def `subroutine actions` [
    command: string
    ...args: string
] {
    match $command {
        # get => (http get ($env.SUBROUTINE_SERVER)/v1/actions),
        _ => (http get ($env.SUBROUTINE_SERVER)/v1/actions),
        # put => {
        #     let id = uuid_now_v7
        #     http put ($env.SUBROUTINE_SERVER)/v1/actions/($id) -t application/json {
        #         id: ($id),
        #         lineage_id: ($id),
        #         origin_routine_id: null,
        #         title: ($args | first),
        #         content: null,
        #         duration: null,
        #         recurrence: null,
        #         saved: false,
        #         state: {
        #             Backlogged: null,
        #         }
        #     }
        # }
        # "post" => (http post ($env.SUBROUTINE_SERVER)/v1/actions),
    }
}

# def `subroutine routines` [command] {
#     match command {
#         "get" => (http get ($env.SUBROUTINE_SERVER)/v1/routines),
#         "
#     }
# }

# export def subroutine [command] {
#     match command {
#         "routines" => (http get ($env.SUBROUTINE_SERVER)/v1/routines),
#     }
# }
