
export def main [
    path1: path
    path2: path
    --verbose(-v)
] {
    rclone bisync --conflict-resolve newer --verbose=$verbose $path1 $path2
}

export def `sync marlin` [] {
    main ~/School marlin:/s/bach/g/under/bcfelix/School
}


