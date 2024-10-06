// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UI",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "UI",
            targets: ["UI"]),
    ],
    targets: [
        .target(
            name: "UI",
            resources: [
                .process("Resources")
            ])
    ]
)
