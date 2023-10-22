import Foundation
import UIKit

public actor ImageFetcher {
    public enum ImageFetcherError: Error {
        case error
    }
    
    private var cache: ImageCacheType
    private var activeDownloads: [URL: Task<UIImage, Error>] = [:]
    
    public init(cache: ImageCacheType = ImageCache()) {
        self.cache = cache
    }
    
    public func fetchImage(from url: URL) async throws -> UIImage {
        if let image = await cache.image(for: url) {
            return image
        } else if let task = activeDownloads[url] {
            return try await task.value
        }
        
        let task: Task<UIImage, Error> = Task.detached {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { throw ImageFetcherError.error }
            return image
        }
        
        activeDownloads[url] = task

        do {
            let image = try await task.value
            activeDownloads[url] = nil
            await cache.insertImage(image, for: url)
            return image
        } catch {
            activeDownloads[url] = nil
            await cache.removeImage(for: url)
            throw error
        }
    }
    
    public func clear() async {
        await cache.removeAllImages()
    }
}
