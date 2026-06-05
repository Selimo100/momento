import SwiftUI

struct RootView: View {
    @AppStorage("accentColorHex") private var accentColorHex = "a0c1b9"

    var body: some View {
        TabView {
            Tab("Momento", systemImage: "photo.on.rectangle.angled") {
                MomentListView()
            }
            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .tint(Color(hex: accentColorHex))
    }
}
