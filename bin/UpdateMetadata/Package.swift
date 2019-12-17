// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UpdateMetadata",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
    ],
    targets: [
        .executableTarget(
            name: "UpdateMetadata",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
