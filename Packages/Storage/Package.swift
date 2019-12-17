// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Storage",
            targets: ["Storage"]
        )
    ],
    dependencies: [
        .package(path: "../Entity"),
        .package(path: "../MockSupport"),
    ],
    targets: [
        .target(
            name: "Storage",
            dependencies: ["Entity", "MockSupport"],
            path: "Sources"
        )
    ]
)
