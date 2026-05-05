

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
