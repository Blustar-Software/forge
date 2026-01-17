protocol Logger {
    func log(_ message: String)
}

struct ConsoleLogger: Logger {
    func log(_ message: String) {
        print(message)
    }
}

struct ForgeService {
    let logger: any Logger
    func start() {
        logger.log("Forge started")
    }
}

let service = ForgeService(logger: ConsoleLogger())
service.start()