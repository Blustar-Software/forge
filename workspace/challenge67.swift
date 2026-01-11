// Challenge 67: Enum Pattern Matching
// Use a switch with a where clause.

enum Event {
    case temperature(Int)
    case error(String)
}

let event = Event.temperature(1600)

// TODO: Use switch to print 'Overheated' when temp >= 1500
// Otherwise print "Normal"
