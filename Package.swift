// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ios-voice-processor",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ios_voice_processor",
            targets: ["ios_voice_processor"])
    ],
    targets: [
        .target(
            name: "ios_voice_processor",
            linkerSettings: [
                .linkedFramework("AVFoundation")
            ]
        )
    ]
)
