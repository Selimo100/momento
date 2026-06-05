import Foundation
import SwiftData

@Model
final class Moment {
    var id: UUID
    var title: String
    var date: Date
    var momentDescription: String
    var coverPhotoId: UUID?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \MomentPhoto.moment)
    var photos: [MomentPhoto]

    init(
        title: String,
        date: Date = .now,
        momentDescription: String = "",
        coverPhotoId: UUID? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.date = date
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
}
