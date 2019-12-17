// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DefenseTeamListFeature",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "DefenseTeamListFeature",
            targets: ["DefenseTeamListFeature"]
        )
    ],
    dependencies: [
        .package(path: "../AttackTeamListFeature"),
        .package(path: "../CreateDefenseTeamFeature"),
        .package(path: "../Entity"),
        .package(path: "../Mocks"),
        .package(path: "../Networking"),
        .package(path: "../Resources"),
        .package(path: "../SharedViews"),
        .package(path: "../Storage"),
    ],
    targets: [
        .target(
            name: "DefenseTeamListFeature",
            dependencies: [
                "AttackTeamListFeature",
                "CreateDefenseTeamFeature",
                "Entity",
                "Networking",
                "Resources",
                "SharedViews",
                "Storage",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "DefenseTeamListFeatureTests",
            dependencies: ["DefenseTeamListFeature", "Mocks"],
            path: "Tests"
        )
    ]
)
