// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MockSupport",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "MockSupport",
            targets: ["MockSupport"]
        )
    ],
    targets: [
        .target(
            name: "MockSupport",
            path: "Sources"
        )
    ]
)
