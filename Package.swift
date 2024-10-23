// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ios-voice-processor",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "ios-voice-processor",
            targets: ["ios-voice-processor"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ios-voice-processor",
            path: "src",
            linkerSettings: [
                .linkedFramework("AVFoundation")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)