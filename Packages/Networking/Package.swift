// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.6.0"
        ),
        .package(path: "../Entity"),
        .package(path: "../MockSupport"),
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                "Entity",
                "MockSupport",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"],
            path: "Tests"
        )
    ]
)
