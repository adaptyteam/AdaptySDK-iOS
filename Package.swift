// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Adapty",

    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        //        .tvOS(.v15),
        //        .watchOS(.v8),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "AdaptyLogger",
            targets: ["AdaptyLogger"]
        ),
        .library(
            name: "AdaptyCodable",
            targets: ["AdaptyCodable"]
        ),
        .library(
            name: "Adapty",
            targets: ["Adapty"]
        ),
        .library(
            name: "Adapty_KidsMode",
            targets: ["Adapty_KidsMode"]
        ),
        .library(
            name: "AdaptyUIBuilder",
            targets: ["AdaptyUIBuilder"]
        ),
        .library(
            name: "AdaptyUI",
            targets: ["AdaptyUI"]
        ),
        .library(
            name: "AdaptyDeveloperTools",
            targets: ["AdaptyDeveloperTools"]
        ),
        .library(
            name: "AdaptyPlugin",
            targets: ["AdaptyPlugin"]
        ),
    ],
    targets: [
        .target(
            name: "AdaptyLogger",
            dependencies: [],
            path: "Sources.Logger",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "AdaptyCodable",
            dependencies: [],
            path: "Sources.Codable",
            exclude: [
                "CSimdjson",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "AdaptyUIBuilder",
            dependencies: ["AdaptyLogger", "AdaptyCodable"],
            path: "Sources.UIBuilder",
            exclude: [
                "adapty.uibuilder.schema.yaml",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "Adapty",
            dependencies: ["AdaptyUIBuilder", "AdaptyLogger", "AdaptyCodable"],
            path: "Sources",
            exclude: [
                "Events/adapty.events.schema.yaml",
                "Placements/adapty.fallback.schema.yaml",
            ],
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "Adapty_KidsMode",
            dependencies: ["AdaptyUIBuilder", "AdaptyLogger", "AdaptyCodable"],
            path: "Sources.KidsMode",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .define("ADAPTY_KIDS_MODE"),
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "AdaptyUI",
            dependencies: ["AdaptyUIBuilder", "Adapty", "AdaptyLogger"],
            path: "Sources.AdaptyUI",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "AdaptyDeveloperTools",
            dependencies: ["AdaptyUIBuilder", "Adapty", "AdaptyUI", "AdaptyLogger"],
            path: "Sources.DeveloperTools",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "AdaptyPlugin",
            dependencies: ["AdaptyUIBuilder", "Adapty", "AdaptyUI", "AdaptyLogger"],
            path: "Sources.AdaptyPlugin",
            exclude: [
                "cross_platform.yaml",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "AdaptyTests",
            dependencies: ["AdaptyUIBuilder", "Adapty", "AdaptyLogger"],
            path: "Tests",
            resources: [
                .process("Placements/fallback.json"),
                .process("Placements/fallback_large.json"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)

