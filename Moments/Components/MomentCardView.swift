import SwiftUI

struct MomentCardView: View {
    let moment: Moment
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("accentColorHex") private var accentColorHex = "a0c1b9"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            coverImageArea
            infoArea
            completionStrip
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(
            color: .black.opacity(colorScheme == .dark ? 0.25 : 0.09),
            radius: 14,
            x: 0,
            y: 5
        )
    }

    @ViewBuilder
    private var coverImageArea: some View {
        ZStack(alignment: .bottomLeading) {
            if let cover = moment.coverPhoto {
                AssetThumbnailView(
                    localIdentifier: cover.localIdentifier,
                    targetSize: CGSize(width: 800, height: 500)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
            } else {
                LinearGradient(
                    colors: [
                        Color(.systemGray5),
                        Color(.systemGray4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 220)
                .overlay {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(.tertiary)
                }
            }

            // Bottom gradient scrim
            LinearGradient(
                colors: [.clear, .black.opacity(0.35)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 220)

            // Photo count badge
            if moment.photos.count > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "photo.stack")
                        .font(.caption2.weight(.semibold))
                    Text("\(moment.photos.count)")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .glassEffect(.regular, in: Capsule())
                .padding(12)
            }
        }
    }

    private var completionStrip: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                Rectangle()
                    .fill(Color(hex: accentColorHex).opacity(0.75))
                    .frame(width: geo.size.width * CGFloat(moment.completionPercentage) / 100)
            }
        }
        .frame(height: 3)
    }

    private var infoArea: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(moment.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let dateText = moment.shortDateDisplay {
                    Text(dateText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let mood = moment.mood {
                    MoodChipView(mood: mood)
                }
            }

            Spacer()

            if moment.favoriteCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                    Text("\(moment.favoriteCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
