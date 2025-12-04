// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Entity",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Entity",
            targets: ["Entity"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.6.0"
        )
    ],
    targets: [
        .target(
            name: "Entity",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "EntityTests",
            dependencies: ["Entity"],
            path: "Tests"
        )
    ]
)
