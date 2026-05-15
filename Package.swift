// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PromptSaver",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "PromptSaver", targets: ["PromptSaver"])
    ],
    targets: [
        .executableTarget(
            name: "PromptSaver",
            resources: [
                .copy("Resources/icon.png")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
