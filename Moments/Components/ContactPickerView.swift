import SwiftUI
@preconcurrency import ContactsUI

struct ContactPickerView: UIViewControllerRepresentable {
    var onSelect: ([String]) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect, dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    // @unchecked Sendable: properties are immutable `let`; UIKit guarantees
    // delegate methods are called on the main thread.
    final class Coordinator: NSObject, CNContactPickerDelegate, @unchecked Sendable {
        let onSelect: ([String]) -> Void
        let dismiss: DismissAction

        init(onSelect: @escaping ([String]) -> Void, dismiss: DismissAction) {
            self.onSelect = onSelect
            self.dismiss = dismiss
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
            let names = contacts.compactMap { CNContactFormatter.string(from: $0, style: .fullName) }
            Task { @MainActor [self] in
                self.onSelect(names)
                self.dismiss()
            }
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            Task { @MainActor [self] in
                self.dismiss()
            }
        }
    }
}
