import Foundation
import SwiftData

@Model
final class Moment {
    var id: UUID
    var title: String
    var startDate: Date?
    var endDate: Date?
    var momentDescription: String
    var coverPhotoId: UUID?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \MomentPhoto.moment)
    var photos: [MomentPhoto]

    init(
        title: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        momentDescription: String = "",
        coverPhotoId: UUID? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.momentDescription = momentDescription
        self.coverPhotoId = coverPhotoId
        self.createdAt = .now
        self.updatedAt = .now
        self.photos = []
    }

    var favoriteCount: Int {
        photos.filter(\.isFavorite).count
    }

    var coverPhoto: MomentPhoto? {
        if let coverPhotoId {
            return photos.first { $0.id == coverPhotoId }
        }
        return photos.sorted { $0.addedAt < $1.addedAt }.first
    }

    var dateDisplay: String? {
        guard let start = startDate else { return nil }
        if let end = endDate, end > start {
            return DateFormatter.momentRange(from: start, to: end)
        }
        return DateFormatter.momentDate.string(from: start)
    }

    var shortDateDisplay: String? {
        guard let start = startDate else { return nil }
        if let end = endDate, end > start {
            return DateFormatter.momentShortRange(from: start, to: end)
        }
        return DateFormatter.momentShort.string(from: start)
    }
}
