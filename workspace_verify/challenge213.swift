protocol Coordinator {
    func start()
}

struct AppCoordinator: Coordinator {
    func start() {
        print("Start")
    }
}

let coordinator = AppCoordinator()
coordinator.start()