@dynamicCallable
struct KeyedAdder {
    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Int {
        return args.reduce(0) { $0 + $1.value }
    }
}

let adder = KeyedAdder()
print(adder(a: 1, b: 2, c: 3))