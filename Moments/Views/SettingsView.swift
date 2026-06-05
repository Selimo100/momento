import SwiftUI

private let defaultAccentHex = "a0c1b9"

struct SettingsView: View {
    @AppStorage("albumPrefix") private var albumPrefix = "Momento –"
    @AppStorage("accentColorHex") private var accentColorHex = defaultAccentHex

    @State private var pickerColor: Color = Color(hex: defaultAccentHex)
    @State private var pickerSynced = false

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
                    ColorPicker("Accent Color", selection: $pickerColor, supportsOpacity: false)
                        .onChange(of: pickerColor) { _, newColor in
                            accentColorHex = newColor.hexString
                        }

                    Button("Reset to Default") {
                        pickerColor = Color(hex: defaultAccentHex)
                        accentColorHex = defaultAccentHex
                    }
                    .foregroundStyle(.secondary)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("The accent color is used for buttons, toggles, and interactive elements throughout the app.")
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
            .onAppear {
                if !pickerSynced {
                    pickerColor = Color(hex: accentColorHex)
                    pickerSynced = true
                }
            }
        }
    }

    @ViewBuilder
    private func privacyRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(Color(hex: accentColorHex))
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
    }
}
