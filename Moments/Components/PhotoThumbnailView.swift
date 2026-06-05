import SwiftUI

struct PhotoThumbnailView: View {
    let photo: MomentPhoto
    let isCover: Bool
    let targetSize: CGSize
    let cornerRadius: CGFloat
    let onTap: () -> Void

    init(
        photo: MomentPhoto,
        isCover: Bool,
        targetSize: CGSize = CGSize(width: 200, height: 200),
        cornerRadius: CGFloat = 10,
        onTap: @escaping () -> Void
    ) {
        self.photo = photo
        self.isCover = isCover
        self.targetSize = targetSize
        self.cornerRadius = cornerRadius
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                AssetThumbnailView(localIdentifier: photo.localIdentifier, targetSize: targetSize)
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

                VStack(alignment: .trailing, spacing: 3) {
                    if isCover {
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
        .buttonStyle(.plain)
    }
}
