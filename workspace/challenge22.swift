// Challenge 22: Pattern Matching
// Use switch to match ranges

let temperature = 1450

// TODO: Use switch on temperature
// - 0...1199: print "Too cold"
// - 1200...1499: print "Working"
// - 1500...: print "Overheated"
switch temperature {
case 0...1199:
    print("Too cold")
case 1200...1499:
    print("Working")
default:
    print("Overheated")
}
