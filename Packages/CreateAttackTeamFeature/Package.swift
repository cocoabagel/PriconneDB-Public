// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CreateAttackTeamFeature",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "CreateAttackTeamFeature",
            targets: ["CreateAttackTeamFeature"]
        )
    ],
    dependencies: [
        .package(path: "../Entity"),
        .package(path: "../FilterUnitsFeature"),
        .package(path: "../Mocks"),
        .package(path: "../Networking"),
        .package(path: "../Resources"),
        .package(path: "../SharedViews"),
        .package(path: "../Storage")
    ],
    targets: [
        .target(
            name: "CreateAttackTeamFeature",
            dependencies: [
                "Entity",
                "FilterUnitsFeature",
                "Networking",
                "Resources",
                "SharedViews",
                "Storage"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "CreateAttackTeamFeatureTests",
            dependencies: ["CreateAttackTeamFeature", "Mocks"],
            path: "Tests"
        )
    ]
)
