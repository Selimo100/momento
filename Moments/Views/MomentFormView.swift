import SwiftUI
import SwiftData

struct MomentFormView: View {
    enum Mode {
        case create
        case edit(Moment)
    }

    let mode: Mode
    var onSave: ((Moment) -> Void)?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var date = Date()
    @State private var momentDescription = ""
    @State private var showValidationError = false

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .font(.body)

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    TextField("Description", text: $momentDescription, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.body)
                } footer: {
                    if showValidationError {
                        Text("Please enter a title.")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Moment" : "New Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear { prefill() }
    }

    private func prefill() {
        if case .edit(let moment) = mode {
            title = moment.title
            date = moment.date
            momentDescription = moment.momentDescription
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showValidationError = true
            return
        }

        switch mode {
        case .create:
            let moment = Moment(title: trimmed, date: date, momentDescription: momentDescription)
            context.insert(moment)
            try? context.save()
            dismiss()
            onSave?(moment)

        case .edit(let moment):
            moment.title = trimmed
            moment.date = date
            moment.momentDescription = momentDescription
            moment.updatedAt = .now
            try? context.save()
            dismiss()
        }
    }
}
