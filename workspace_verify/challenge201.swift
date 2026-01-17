@dynamicCallable
struct Multiplier {
    func dynamicallyCall(withArguments args: [Int]) -> Int {
        return args.reduce(1, *)
    }
}

let multiply = Multiplier()
print(multiply(2, 3, 4))