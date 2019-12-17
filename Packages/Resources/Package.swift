// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Resources",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Resources",
            targets: ["Resources"]
        )
    ],
    targets: [
        .target(
            name: "Resources",
            path: "Sources",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
