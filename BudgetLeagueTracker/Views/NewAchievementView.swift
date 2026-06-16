import SwiftUI
import SwiftData

/// Legacy wrapper — prefer `AchievementFormView` directly.
struct NewAchievementView: View {
    let context: ModelContext
    var onAdd: (() -> Void)?
    var onCancel: (() -> Void)?

    init(viewModel: NewAchievementViewModel) {
        self.context = viewModel.context
        self.onAdd = viewModel.onAdd
        self.onCancel = viewModel.onCancel
    }

    var body: some View {
        AchievementFormView(
            viewModel: makeFormViewModel()
        )
    }

    private func makeFormViewModel() -> AchievementFormViewModel {
        let vm = AchievementFormViewModel(context: context, mode: .add(template: nil))
        vm.onSave = onAdd
        vm.onCancel = onCancel
        return vm
    }
}

#Preview {
    NewAchievementView(viewModel: NewAchievementViewModel(context: PreviewContainer.shared.mainContext))
}
