struct Vault {
    private var code: Int

    init(code: Int) {
        self.code = code
    }
}

let _ = Vault(code: 1234)
print("Vault ready")