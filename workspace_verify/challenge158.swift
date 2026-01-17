// Challenge 158: Class Shared State
// Show reference semantics.

class Controller {
    var mode: String
    init(mode: String) {
        self.mode = mode
    }
}

let primary = Controller(mode: "Idle")
let secondary = primary

secondary.mode = "Active"
print(primary.mode)
// TODO: Print 'primary.mode'