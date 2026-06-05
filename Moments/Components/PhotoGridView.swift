import SwiftUI

struct PhotoGridView: View {
    let photos: [MomentPhoto]
    let coverPhotoId: UUID?
    let onTap: (MomentPhoto) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(photos.sorted { $0.addedAt < $1.addedAt }) { photo in
                PhotoThumbnailView(
                    photo: photo,
                    isCover: photo.id == coverPhotoId,
                    targetSize: CGSize(width: 200, height: 200),
                    cornerRadius: 10
                ) {
                    onTap(photo)
                }
            }
        }
    }
}
