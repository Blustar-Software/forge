protocol Clock {
    func now() -> Int
}

struct MockClock: Clock {
    let value: Int
    func now() -> Int { value }
}

func report(_ clock: any Clock) {
    print("Now: \(clock.now())")
}

report(MockClock(value: 5))