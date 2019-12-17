// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AttackTeamListFeature",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "AttackTeamListFeature",
            targets: ["AttackTeamListFeature"]
        )
    ],
    dependencies: [
        .package(path: "../CreateAttackTeamFeature"),
        .package(path: "../Entity"),
        .package(path: "../Mocks"),
        .package(path: "../Networking"),
        .package(path: "../Resources"),
        .package(path: "../SharedViews"),
    ],
    targets: [
        .target(
            name: "AttackTeamListFeature",
            dependencies: [
                "CreateAttackTeamFeature",
                "Entity",
                "Networking",
                "Resources",
                "SharedViews",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AttackTeamListFeatureTests",
            dependencies: ["AttackTeamListFeature", "Mocks"],
            path: "Tests"
        )
    ]
)
