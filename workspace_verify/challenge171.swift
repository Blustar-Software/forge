class Logger {
    let prefix: String
    init(prefix: String) {
        self.prefix = prefix
    }

    func makePrinter() -> () -> Void {
        return { [weak self] in
            if let self = self {
                print(self.prefix)
            }
        }
    }
}

let logger = Logger(prefix: "Log")
let printer = logger.makePrinter()
printer()