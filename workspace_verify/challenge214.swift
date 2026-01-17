protocol InventoryRepository {
    func loadItems() -> [String]
}

struct MemoryInventoryRepository: InventoryRepository {
    let items: [String]
    func loadItems() -> [String] { items }
}

struct InventoryService {
    let repository: any InventoryRepository
    func count() -> Int {
        return repository.loadItems().count
    }
}

let service = InventoryService(repository: MemoryInventoryRepository(items: ["Iron", "Gold"]))
print("Count: \(service.count())")