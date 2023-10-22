import Foundation
import UIKit

public actor ImageFetcher {
    
    public enum ImageFetcherError: Error {
        case fetchError
    }
    
    public static let shared = ImageFetcher(cache: ImageCache())
    
    private let cache: ImageCacheType
    private var runningTasks: [URL: Task<UIImage, Error>] = [:]

    public init(cache: ImageCacheType) {
        self.cache = cache
    }
    
    public func fetchImage(from url: URL) async throws -> UIImage? {
        if let task = runningTasks[url] {
            return try await task.value
        } else if let image = cache.image(for: url) {
            return image
        }

        let task: Task<UIImage, Error> = Task.detached {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { throw ImageFetcherError.fetchError }
            return image
        }
        
        runningTasks[url] = task
        
        do {
            let image = try await task.value
            runningTasks[url] = nil
            cache[url] = image
            return image
        } catch {
            runningTasks[url] = nil
            cache[url] = nil
            throw error
        }
    }
}
