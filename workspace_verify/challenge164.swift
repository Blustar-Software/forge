struct Vault {
    private var code: Int

    var masked: String {
        return "****"
    }

    init(code: Int) {
        self.code = code
    }
}

let vault = Vault(code: 1234)
print(vault.masked)