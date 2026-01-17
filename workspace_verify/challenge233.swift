@dynamicMemberLookup
struct Defaults {
    var values: [String: Int]
    subscript(dynamicMember member: String) -> Int {
        return values[member, default: 0]
    }
}

let defaults = Defaults(values: ["limit": 5])
print("Limit: \(defaults.limit)")
print("Missing: \(defaults.missing)")