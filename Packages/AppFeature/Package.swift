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
        .package(path: "../DefenseTeamListFeature"),
        .package(path: "../SearchViewFeature"),
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "DefenseTeamListFeature",
                "SearchViewFeature",
            ],
            path: "Sources"
        )
    ]
)
