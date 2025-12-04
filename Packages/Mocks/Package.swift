// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Mocks",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "Mocks",
            targets: ["Mocks"]
        )
    ],
    dependencies: [
        .package(path: "../Entity"),
        .package(path: "../MockSupport"),
        .package(path: "../Networking"),
        .package(path: "../Storage")
    ],
    targets: [
        .target(
            name: "Mocks",
            dependencies: ["Entity", "MockSupport", "Networking", "Storage"],
            path: "Sources"
        )
    ]
)
