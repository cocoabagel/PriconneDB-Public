// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CreateDefenseTeamFeature",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "CreateDefenseTeamFeature",
            targets: ["CreateDefenseTeamFeature"]
        )
    ],
    dependencies: [
        .package(path: "../Entity"),
        .package(path: "../FilterUnitsFeature"),
        .package(path: "../Mocks"),
        .package(path: "../Networking"),
        .package(path: "../Resources"),
        .package(path: "../SharedViews"),
        .package(path: "../Storage"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.2"),
        .package(url: "https://github.com/yeatse/KingfisherWebP.git", from: "1.7.2")
    ],
    targets: [
        .target(
            name: "CreateDefenseTeamFeature",
            dependencies: [
                "Entity",
                "FilterUnitsFeature",
                "Networking",
                "Resources",
                "SharedViews",
                "Storage",
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "KingfisherWebP", package: "KingfisherWebP")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "CreateDefenseTeamFeatureTests",
            dependencies: ["CreateDefenseTeamFeature", "Mocks"],
            path: "Tests"
        )
    ]
)
