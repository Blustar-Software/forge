struct Tag {
    var label: String
}

class ForgeController {
    var status: String
    init(status: String) {
        self.status = status
    }
}

let tag = Tag(label: "Batch-A")
let controller = ForgeController(status: "Online")
print(tag.label)
print(controller.status)