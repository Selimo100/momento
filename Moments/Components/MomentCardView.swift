import SwiftUI

struct MomentCardView: View {
    let moment: Moment

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            coverImageArea
            infoArea
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 3)
    }

    @ViewBuilder
    private var coverImageArea: some View {
        ZStack(alignment: .bottomLeading) {
            if let cover = moment.coverPhoto {
                AssetThumbnailView(
                    localIdentifier: cover.localIdentifier,
                    targetSize: CGSize(width: 400, height: 300)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray5), Color(.systemGray4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                    .overlay {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(.tertiary)
                    }
            }

            if moment.photos.count > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "photo.stack")
                        .font(.caption2.weight(.semibold))
                    Text("\(moment.photos.count)")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .glassEffect(.regular, in: Capsule())
                .padding(10)
            }
        }
    }

    private var infoArea: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(moment.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            HStack {
                Text(moment.date.momentShortFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if moment.favoriteCount > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundStyle(.pink)
                        Text("\(moment.favoriteCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
