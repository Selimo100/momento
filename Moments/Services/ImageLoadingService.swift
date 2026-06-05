import UIKit
import Photos

actor ImageLoadingService {
    static let shared = ImageLoadingService()
    private let imageManager = PHCachingImageManager()
    private var cache: [String: UIImage] = [:]

    private init() {}

    func thumbnail(for identifier: String, targetSize: CGSize = CGSize(width: 300, height: 300)) async -> UIImage? {
        let cacheKey = "\(identifier)-\(Int(targetSize.width))"
        if let cached = cache[cacheKey] {
            return cached
        }

        let result = await fetchImage(identifier: identifier, targetSize: targetSize, contentMode: .aspectFill)
        if let result {
            cache[cacheKey] = result
        }
        return result
    }

    func fullResolution(for identifier: String) async -> UIImage? {
        await fetchImage(identifier: identifier, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit)
    }

    private func fetchImage(identifier: String, targetSize: CGSize, contentMode: PHImageContentMode) async -> UIImage? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = assets.firstObject else { return nil }

        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = targetSize == PHImageManagerMaximumSize ? .highQualityFormat : .opportunistic
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true

            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options
            ) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if !isDegraded {
                    continuation.resume(returning: image)
                } else if image != nil && targetSize != PHImageManagerMaximumSize {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    func clearCache() {
        cache.removeAll()
    }
}
