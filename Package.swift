// swift-tools-version: 5.7.1

import PackageDescription

let package = Package(
    name: "ios_voice_processor",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "ios_voice_processor",
            targets: ["ios_voice_processor"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ios_voice_processor",
            dependencies: [],
            exclude: [
                "example"
            ]),
    ]
)