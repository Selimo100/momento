import SwiftUI

struct SettingsView: View {
    @AppStorage("albumPrefix") private var albumPrefix = "Momento –"

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Version", value: appVersion)
                } header: { Text("App") }

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Default Album Prefix")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("Prefix", text: $albumPrefix)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Export Preferences")
                } footer: {
                    Text("Album names will be formatted as: \"\(albumPrefix) <Moment Title>\"")
                }

                Section {
                    privacyRow(icon: "lock.iphone", text: "All data stays on this device.")
                    privacyRow(icon: "person.slash", text: "No account or login required.")
                    privacyRow(icon: "server.rack", text: "No backend or cloud service.")
                    privacyRow(icon: "photo", text: "Photos are only accessed when you choose them.")
                    privacyRow(icon: "square.and.arrow.up", text: "Export to Apple Photos only happens when you tap Export.")
                } header: { Text("Privacy") }
            }
            .navigationTitle("Settings")
        }
    }

    @ViewBuilder
    private func privacyRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(Color.accentColor)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
    }
}
