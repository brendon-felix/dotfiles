
# ---------------------------------------------------------------------------- #
#                                interpolate.nu                                #
# ---------------------------------------------------------------------------- #

# def interpolate_record [
#     start
#     end
#     t?: float = 0.5
# ] {
#     for v in ($start | values | append ($end | values)) {
#         if not ((($v | describe) == "int") or (($v | describe) == "float")) {
#             error make {
#                 msg: "invalid type"
#                 label: {
#                     text: "value must be numeric"
#                     span: (metadata $v).span
#                 }
#             }
#         }
#     }
#     match $t {
#         $t if $t <= 0 => $start
#         $t if $t >= 1 => $end
#         _ => {
#             $start | items {|k v|
#                 mut new = $v + (($end | get $k) - $v) * $t
#                 if ($v | describe) == "int" {
#                     $new = $new | into int
#                 }
#                 {$k: $new}
#             } | into record
#         }
#     }
# }

# def interpolate_list [
#     start
#     end
#     t?: float = 0.5
# ] {
#     for v in ($start | append $end) {
#         if not ((($v | describe) == "int") or (($v | describe) == "float")) {
#             error make {
#                 msg: "invalid type"
#                 label: {
#                     text: "value must be numeric"
#                     span: (metadata $v).span
#                 }
#             }
#         }
#     }
#     match $t {
#         $t if $t <= 0 => $start
#         $t if $t >= 1 => $end
#         _ => {
#             $start | zip $end | each {|e|
#                 mut new_value = $e.0 + ($e.1 - $e.0) * $t
#                 if (($e.0 | describe) == "int") {
#                     $new_value = $new_value | into int
#                 }
#                 $new_value
#             }
#         }
#     }
# }

export def main [
    other: number
    t?: float = 0.5
]: [
    number -> number
    list<number> -> list<number>
] {
    each {|n|
        let m = $other
        match $t {
            $t if $t <= 0 => $n
            $t if $t >= 1 => $m
            _ => ($n + ($m - $n) * $t)
        }
    }
}
