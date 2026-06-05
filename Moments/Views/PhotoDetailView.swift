import SwiftUI

struct PhotoDetailView: View {
    let moment: Moment
    let initialPhoto: MomentPhoto
    let onFavoriteToggle: (MomentPhoto) -> Void
    let onSetCover: (MomentPhoto) -> Void
    let onRemove: (MomentPhoto) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int
    @State private var showRemoveConfirmation = false

    init(
        moment: Moment,
        initialPhoto: MomentPhoto,
        onFavoriteToggle: @escaping (MomentPhoto) -> Void,
        onSetCover: @escaping (MomentPhoto) -> Void,
        onRemove: @escaping (MomentPhoto) -> Void
    ) {
        self.moment = moment
        self.initialPhoto = initialPhoto
        self.onFavoriteToggle = onFavoriteToggle
        self.onSetCover = onSetCover
        self.onRemove = onRemove
        let sorted = moment.photos.sorted { $0.addedAt < $1.addedAt }
        let idx = sorted.firstIndex(where: { $0.id == initialPhoto.id }) ?? 0
        self._currentIndex = State(initialValue: idx)
    }

    private var sortedPhotos: [MomentPhoto] {
        moment.photos.sorted { $0.addedAt < $1.addedAt }
    }

    private var currentPhoto: MomentPhoto? {
        guard currentIndex < sortedPhotos.count else { return nil }
        return sortedPhotos[currentIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                TabView(selection: $currentIndex) {
                    ForEach(Array(sortedPhotos.enumerated()), id: \.element.id) { index, photo in
                        PhotoPageView(photo: photo)
                            .tag(index)
                            .ignoresSafeArea()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
            }
            .navigationTitle(sortedPhotos.count > 1 ? "\(currentIndex + 1) of \(sortedPhotos.count)" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    if let photo = currentPhoto {
                        actionBar(for: photo)
                    }
                }
            }
            .confirmationDialog(
                "Remove Photo",
                isPresented: $showRemoveConfirmation,
                titleVisibility: .visible
            ) {
                Button("Remove from Moment", role: .destructive) {
                    if let photo = currentPhoto {
                        onRemove(photo)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will only remove the photo from this moment. The original photo in Apple Photos is not affected.")
            }
            .onChange(of: moment.photos.count) { _, newCount in
                if newCount == 0 {
                    dismiss()
                } else if currentIndex >= newCount {
                    currentIndex = newCount - 1
                }
            }
        }
    }

    private func actionBar(for photo: MomentPhoto) -> some View {
        HStack(spacing: 0) {
            actionButton(
                icon: photo.isFavorite ? "heart.fill" : "heart",
                label: "Favorite",
                tint: photo.isFavorite ? .pink : .white
            ) {
                onFavoriteToggle(photo)
            }

            actionButton(
                icon: moment.coverPhotoId == photo.id ? "star.fill" : "star",
                label: "Cover",
                tint: moment.coverPhotoId == photo.id ? .yellow : .white
            ) {
                onSetCover(photo)
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
    private func actionButton(
        icon: String,
        label: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
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

// MARK: - Page

private struct PhotoPageView: View {
    let photo: MomentPhoto
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color.black
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
        .task(id: photo.localIdentifier) {
            image = await ImageLoadingService.shared.fullResolution(for: photo.localIdentifier)
        }
    }
}
