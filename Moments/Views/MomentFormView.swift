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
    @State private var momentDescription = ""
    @State private var showValidationError = false

    @State private var hasDate = false
    @State private var isDateRange = false
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now

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

                Section {
                    Toggle("Set a date", isOn: $hasDate.animation())

                    if hasDate {
                        DatePicker("Start date", selection: $startDate, displayedComponents: .date)

                        Toggle("Date range", isOn: $isDateRange.animation())

                        if isDateRange {
                            DatePicker(
                                "End date",
                                selection: $endDate,
                                in: startDate...,
                                displayedComponents: .date
                            )
                        }
                    }
                } header: {
                    Text("When")
                } footer: {
                    if hasDate && isDateRange {
                        Text("A date range lets you capture a period, like a trip or an event.")
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
            momentDescription = moment.momentDescription
            if let start = moment.startDate {
                hasDate = true
                startDate = start
                if let end = moment.endDate {
                    isDateRange = true
                    endDate = end
                }
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showValidationError = true
            return
        }

        let resolvedStart: Date? = hasDate ? startDate : nil
        let resolvedEnd: Date? = (hasDate && isDateRange) ? endDate : nil

        switch mode {
        case .create:
            let moment = Moment(
                title: trimmed,
                startDate: resolvedStart,
                endDate: resolvedEnd,
                momentDescription: momentDescription
            )
            context.insert(moment)
            try? context.save()
            dismiss()
            onSave?(moment)

        case .edit(let moment):
            moment.title = trimmed
            moment.momentDescription = momentDescription
            moment.startDate = resolvedStart
            moment.endDate = resolvedEnd
            moment.updatedAt = .now
            try? context.save()
            dismiss()
        }
    }
}
