// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Environment",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Environment",
            targets: ["Environment"]
        )
    ],
    dependencies: [
        .package(path: "../Entity"),
        .package(path: "../SharedViews")
    ],
    targets: [
        .target(
            name: "Environment",
            dependencies: [
                "Entity",
                "SharedViews"
            ],
            path: "Sources"
        )
    ]
)
