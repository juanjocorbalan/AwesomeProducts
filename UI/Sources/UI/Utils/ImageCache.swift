import Foundation
import UIKit

public protocol ImageCacheType: AnyObject {
    func image(for key: URL) -> UIImage?
    func insertImage(_ image: UIImage?, for key: URL)
    func removeImage(for key: URL)
    func removeAllImages()
    subscript(_ key: URL) -> UIImage? { get set }
}

public final class ImageCache: ImageCacheType {
    
    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = settings.countLimit
        return cache
    }()
    
    private let lock = NSLock()
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
    
    public subscript(_ key: URL) -> UIImage? {
        get { return image(for: key) }
        set { return insertImage(newValue, for: key) }
    }
}

extension URL {
    var asNSString: NSString {
        self.absoluteString as NSString
    }
}
