import Foundation
import UIKit

@MainActor
public protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

public protocol StoryboardInitializable: StoryboardIdentifiable {
    static func initFromStoryboard(name: String) -> Self
}

public extension StoryboardInitializable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: Self.self)
    }
    
    static func initFromStoryboard(name: String = "Main") -> Self {
        let storyboard = UIStoryboard(name: name, bundle: Bundle(for: Self.self))
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}

public extension StoryboardIdentifiable where Self: UICollectionViewCell {
    static var storyboardIdentifier: String {
        return String(describing: Self.self)
    }
}
