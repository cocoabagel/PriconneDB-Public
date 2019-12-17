// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FilterUnitsFeature",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "FilterUnitsFeature",
            targets: ["FilterUnitsFeature"]
        )
    ],
    dependencies: [
        .package(path: "../Entity"),
        .package(path: "../Mocks"),
        .package(path: "../Networking"),
        .package(path: "../SharedViews"),
        .package(path: "../Storage"),
    ],
    targets: [
        .target(
            name: "FilterUnitsFeature",
            dependencies: [
                "Entity",
                "Networking",
                "SharedViews",
                "Storage",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FilterUnitsFeatureTests",
            dependencies: ["FilterUnitsFeature", "Mocks"],
            path: "Tests"
        )
    ]
)
