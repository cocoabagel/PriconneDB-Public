// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SharedViews",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "SharedViews",
            targets: ["SharedViews"]
        )
    ],
    dependencies: [
        .package(path: "../Entity"),
        .package(path: "../Resources"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.2"),
        .package(url: "https://github.com/yeatse/KingfisherWebP.git", from: "1.7.2")
    ],
    targets: [
        .target(
            name: "SharedViews",
            dependencies: [
                "Entity",
                "Resources",
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "KingfisherWebP", package: "KingfisherWebP")
            ],
            path: "Sources"
        )
    ]
)
