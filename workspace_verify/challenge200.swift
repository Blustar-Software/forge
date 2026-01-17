@dynamicMemberLookup
struct Settings {
    var values: [String: String]
    subscript(dynamicMember member: String) -> String {
        return values[member, default: ""]
    }
}

let settings = Settings(values: ["mode": "safe", "level": "3"])
print(settings.mode)
print(settings.level)