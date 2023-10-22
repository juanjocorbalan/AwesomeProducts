import Foundation
import UIKit

public protocol ImageCacheType: AnyObject {
    func image(for key: URL) async -> UIImage?
    func insertImage(_ image: UIImage?, for key: URL) async
    func removeImage(for key: URL) async
    func removeAllImages() async
}

public final actor ImageCache: ImageCacheType {
    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = settings.countLimit
        return cache
    }()
    
    private let settings: CacheSettings
    
    public struct CacheSettings {
        let countLimit: Int
        
        public static let defaultSettings = CacheSettings(countLimit: 50)
    }
    
    public init(settings: CacheSettings = CacheSettings.defaultSettings) {
        self.settings = settings
    }
    
    public func image(for key: URL) -> UIImage? {
        return imageCache.object(forKey: key.asNSString)
    }
    
    public func insertImage(_ image: UIImage?, for key: URL) {
        guard let image = image else { return removeImage(for: key) }
        imageCache.setObject(image, forKey: key.asNSString, cost: 1)
    }
    
    public func removeImage(for key: URL) {
        imageCache.removeObject(forKey: key.asNSString)
    }
    
    public func removeAllImages() {
        imageCache.removeAllObjects()
    }
}

extension URL {
    var asNSString: NSString {
        self.absoluteString as NSString
    }
}
