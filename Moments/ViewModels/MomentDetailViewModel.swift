import SwiftUI
import SwiftData
import Photos
import PhotosUI

enum ExportScope {
    case all, favoritesOnly
}

@MainActor
@Observable
final class MomentDetailViewModel {
    var showingPhotoPicker = false
    var showingExportSheet = false
    var showingPhotoDetail = false
    var selectedPhoto: MomentPhoto?

    var isExporting = false
    var exportResultMessage: String?
    var showExportResult = false
    var exportAlbumName = ""

    var photoPickerItems: [PhotosPickerItem] = []

    func loadPickerItems(_ items: [PhotosPickerItem], into moment: Moment, context: ModelContext) async {
        for item in items {
            if let identifier = item.itemIdentifier {
                let alreadyExists = moment.photos.contains { $0.localIdentifier == identifier }
                if !alreadyExists {
                    let photo = MomentPhoto(localIdentifier: identifier)
                    photo.moment = moment
                    moment.photos.append(photo)
                }
            }
        }
        moment.updatedAt = .now
        try? context.save()
    }

    func toggleFavorite(_ photo: MomentPhoto, in moment: Moment, context: ModelContext) {
        photo.isFavorite.toggle()
        moment.updatedAt = .now
        try? context.save()
    }

    func setCover(_ photo: MomentPhoto, in moment: Moment, context: ModelContext) {
        moment.coverPhotoId = photo.id
        moment.updatedAt = .now
        try? context.save()
    }

    func removePhoto(_ photo: MomentPhoto, from moment: Moment, context: ModelContext) {
        if moment.coverPhotoId == photo.id {
            let remaining = moment.photos.filter { $0.id != photo.id }
            moment.coverPhotoId = remaining.first?.id
        }
        moment.photos.removeAll { $0.id == photo.id }
        context.delete(photo)
        moment.updatedAt = .now
        try? context.save()
    }

    func export(moment: Moment, scope: ExportScope) async {
        isExporting = true

        let candidates: [MomentPhoto]
        switch scope {
        case .all:
            candidates = moment.photos
        case .favoritesOnly:
            candidates = moment.photos.filter(\.isFavorite)
        }

        guard !candidates.isEmpty else {
            exportResultMessage = scope == .favoritesOnly
                ? "There are no favorite photos in this moment."
                : "This moment has no photos to export."
            showExportResult = true
            isExporting = false
            return
        }

        let identifiers = candidates.map(\.localIdentifier)
        let result = await PhotoExportService.shared.export(
            identifiers: identifiers,
            toAlbumNamed: exportAlbumName
        )

        switch result {
        case .success(let count, let album):
            exportResultMessage = "Exported \(count) \(count == 1 ? "photo" : "photos") to \"\(album)\"."
        case .partial(let exported, let total, let album):
            exportResultMessage = "Exported \(exported) of \(total) photos to \"\(album)\". \(total - exported) photos could not be found."
        case .failure(let error):
            exportResultMessage = error.errorDescription
        }

        isExporting = false
        showExportResult = true
        showingExportSheet = false
    }

    func defaultAlbumName(for moment: Moment, prefix: String) -> String {
        "\(prefix) \(moment.title)"
    }
}
