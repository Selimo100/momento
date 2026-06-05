import SwiftUI

struct PhotoGridView: View {
    let photos: [MomentPhoto]
    let coverPhotoId: UUID?
    let onTap: (MomentPhoto) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(photos.sorted { $0.addedAt < $1.addedAt }) { photo in
                photoCell(photo)
                    .onTapGesture { onTap(photo) }
            }
        }
    }

    @ViewBuilder
    private func photoCell(_ photo: MomentPhoto) -> some View {
        let size = CGSize(width: 200, height: 200)
        ZStack(alignment: .topTrailing) {
            AssetThumbnailView(localIdentifier: photo.localIdentifier, targetSize: size)
                .aspectRatio(1, contentMode: .fill)
                .clipped()

            HStack(spacing: 4) {
                if photo.id == coverPhotoId {
                    Image(systemName: "star.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.yellow)
                        .padding(5)
                        .glassEffect(.regular, in: Circle())
                }
                if photo.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.pink)
                        .padding(5)
                        .glassEffect(.regular, in: Circle())
                }
            }
            .padding(5)
        }
    }
}
