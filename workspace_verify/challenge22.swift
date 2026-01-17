// Challenge 22: Pattern Matching
// Use switch to match ranges

let temperature = 1450

switch temperature {
case 0...1199:
    print("Too cold")
case 1200...1499:
    print("Working")
default:
    print("Overheated")
}
// - 0...1199: print "Too cold"
// - 1200...1499: print "Working"
// - 1500...: print "Overheated"