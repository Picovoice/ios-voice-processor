// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ios-voice-processor",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "ios_voice_processor",
            targets: ["ios_voice_processor"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ios_voice_processor",
            linkerSettings: [
                .linkedFramework("AVFoundation")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
