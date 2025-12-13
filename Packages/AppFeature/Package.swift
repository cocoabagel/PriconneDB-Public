// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AppFeature",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        )
    ],
    dependencies: [
        .package(path: "../AttackTeamListFeature"),
        .package(path: "../CreateAttackTeamFeature"),
        .package(path: "../CreateDefenseTeamFeature"),
        .package(path: "../DefenseTeamListFeature"),
        .package(path: "../Environment"),
        .package(path: "../FilterUnitsFeature"),
        .package(path: "../SearchViewFeature")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "AttackTeamListFeature",
                "CreateAttackTeamFeature",
                "CreateDefenseTeamFeature",
                "DefenseTeamListFeature",
                "Environment",
                "FilterUnitsFeature",
                "SearchViewFeature"
            ],
            path: "Sources"
        )
    ]
)
