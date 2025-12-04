// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SearchViewFeature",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "SearchViewFeature",
            targets: ["SearchViewFeature"]
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
            name: "SearchViewFeature",
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
            name: "SearchViewFeatureTests",
            dependencies: ["SearchViewFeature", "Mocks"],
            path: "Tests"
        )
    ]
)
