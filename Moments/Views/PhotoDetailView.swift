import SwiftUI

struct PhotoDetailView: View {
    let photo: MomentPhoto
    let moment: Moment
    let onFavoriteToggle: () -> Void
    let onSetCover: () -> Void
    let onRemove: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var showRemoveConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    actionBar
                }
            }
            .confirmationDialog("Remove Photo", isPresented: $showRemoveConfirmation, titleVisibility: .visible) {
                Button("Remove from Moment", role: .destructive) {
                    onRemove()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will only remove the photo from this moment. The original photo in Apple Photos is not affected.")
            }
        }
        .task {
            image = await ImageLoadingService.shared.fullResolution(for: photo.localIdentifier)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 0) {
            actionButton(
                icon: photo.isFavorite ? "heart.fill" : "heart",
                label: "Favorite",
                tint: photo.isFavorite ? .pink : .white
            ) {
                onFavoriteToggle()
            }

            actionButton(
                icon: moment.coverPhotoId == photo.id ? "star.fill" : "star",
                label: "Cover",
                tint: moment.coverPhotoId == photo.id ? .yellow : .white
            ) {
                onSetCover()
                dismiss()
            }

            actionButton(icon: "trash", label: "Remove", tint: .red) {
                showRemoveConfirmation = true
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    @ViewBuilder
    private func actionButton(icon: String, label: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(tint)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .frame(width: 80)
        }
    }
}
