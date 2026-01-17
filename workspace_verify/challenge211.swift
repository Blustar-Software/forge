struct FurnaceModel {
    let heat: Int
}

struct FurnaceViewModel {
    let model: FurnaceModel
    var status: String {
        return model.heat >= 1200 ? "Ready" : "Cold"
    }
}

let viewModel = FurnaceViewModel(model: FurnaceModel(heat: 1300))
print("Status: \(viewModel.status)")