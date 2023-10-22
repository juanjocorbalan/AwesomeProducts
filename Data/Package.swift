// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Data",
            targets: ["Data"]),
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types")
            ],             
            resources: [
                .process("Mocks")
            ]),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"])
    ]
)
