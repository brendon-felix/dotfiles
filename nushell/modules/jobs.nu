# ---------------------------------------------------------------------------- #
#                                   jobs.nu                                    #
# ---------------------------------------------------------------------------- #

# export def `job recv` [
#     --tag: int
#     --timeout(-t): duration
#     --all(-a)
# ] {
#     if $all {
#         job recv-all --tag=$tag --timeout=$timeout
#     } else {
#         match {tag: $tag, timeout: $timeout} {
# 			{tag: null, timeout: null} => { %job recv }
# 			{$tag, timeout: null} => { %job recv --tag=$tag }
# 			{tag: null, $timeout} => { %job recv --timeout=$timeout }
# 			{$tag, $timeout} => { %job recv --timeout=$timeout --tag=$tag }
# 		}
#     }
# }

export def "job recv-all" [
	--tag: int # A tag for the messages
	--timeout: duration # The maximum time duration to wait for
] {
	null
	generate {|e = null|
		let out = match {tag: $tag, timeout: $timeout} {
			{tag: null, timeout: null} => { %job recv }
			{$tag, timeout: null} => { %job recv --tag=$tag }
			{$tag, $timeout} => {
				try {
					if $tag == null {
						%job recv --timeout=$timeout
					} else {
						%job recv --timeout=$timeout --tag=$tag
					}
				} catch {|err|
					if $err.json has "recv_timeout" { return {} } else { return $err.raw }
				}
			}
		}
		{out: $out, next: null}
	}
}
