# Swift luminance experiment (not adopted)

Run `sh scripts/benchmark-ios-luminance.sh` on a Mac with Xcode. The benchmark
compiles the real current analyzer and a benchmark-only weighted RGB lookup-table
candidate using `swiftc -O`. It verifies exact output equality on 64 deterministic
96×8 RGBX strips with padded rows, warms up both implementations, then alternates
order for ten paired 50,000-iteration rounds. A printed checksum consumes results.

Two batches on the development Apple Silicon Mac produced inconsistent small
changes: first-batch medians approximately 0.342µs baseline / 0.346µs candidate;
second-batch medians approximately 0.350µs / 0.343µs. Raw rounds are retained here.
The candidate was rejected: no repeatable meaningful gain justified extra tables
and complexity. The shipped Swift analyzer remains unchanged. This is an isolated
CPU microbenchmark, not iPhone frame-time, rendering or battery evidence.

The lifecycle improvement is separately proven by `scripts/test-ios-controller.sh`:
100 alternating hints in automatic mode previously reattached the sampling
observer 100 times; now zero times, preserving scheduler/decider state. That is an
operation-count reduction, not a measured app-wide latency or FPS claim.
