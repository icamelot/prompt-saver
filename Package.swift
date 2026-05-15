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
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
