import Foundation

public enum ProductsAPI {
    public static let baseURL = URL(string: "https://dummyjson.com")!

    public enum paths {
        public static let products = "products"
    }
    
    public enum url {
        public static let products = ProductsAPI.baseURL.appendingPathComponent(ProductsAPI.paths.products)
    }
}

public enum ProductCacheKeys {
    public static let id = "id"
    public static let isRemoved = "isRemoved"
}
