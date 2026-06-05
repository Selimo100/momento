import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Momento", systemImage: "photo.on.rectangle.angled") {
                MomentListView()
            }
            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
    }
}
