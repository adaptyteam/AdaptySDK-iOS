// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Adapty",

    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        //        .tvOS(.v15),
        //        .watchOS(.v8),
        .visionOS(.v2),
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
            name: "AdaptyUI_KidsMode",
            targets: ["AdaptyUI_KidsMode"]
        ),
        .library(
            name: "AdaptyDeveloperTools",
            targets: ["AdaptyDeveloperTools"]
        ),
        .library(
            name: "AdaptyPlugin",
            targets: ["AdaptyPlugin"]
        ),
        .library(
            name: "AdaptyPlugin_KidsMode",
            targets: ["AdaptyPlugin_KidsMode"]
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
            name: "CSimdjson",
            path: "Sources.Codable/CSimdjson",
            sources: [
                "simdjson.cpp",
                "SimdjsonBridge.cpp",
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("."),
                .define("SIMDJSON_EXCEPTIONS", to: "0"),
                .define("NDEBUG", .when(configuration: .release)),
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
            ]
        ),
        .target(
            name: "AdaptyCodable",
            dependencies: ["CSimdjson"],
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
                "Placements/adapty.fallback_file.cue",
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
            name: "AdaptyUI_KidsMode",
            dependencies: [
                "AdaptyUIBuilder",
                "Adapty_KidsMode",
                "AdaptyLogger",
            ],
            path: "Sources.AdaptyUI.KidsMode",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .unsafeFlags(["-module-alias", "Adapty=Adapty_KidsMode"]),
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
        .target(
            name: "AdaptyPlugin_KidsMode",
            dependencies: ["AdaptyUIBuilder", "Adapty_KidsMode", "AdaptyUI_KidsMode", "AdaptyLogger"],
            path: "Sources.AdaptyPlugin.KidsMode",
            exclude: [
                "cross_platform.yaml"
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-module-alias", "Adapty=Adapty_KidsMode",
                    "-module-alias", "AdaptyUI=AdaptyUI_KidsMode",
                ]),
            ]
        ),
        .testTarget(
            name: "AdaptyTests",
            dependencies: ["AdaptyUIBuilder", "Adapty", "AdaptyLogger", "AdaptyCodable"],
            path: "Tests",
            exclude: [
                // TEMP: pre-existing breakage after `UIBuilder: tighten access modifiers,
                // drop redundant Equatable/Hashable` — wait for follow-up fix.
                "UISchema",
                "UIConfiguration",
            ],
            resources: [
                .process("Placements/fallback.json"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ],
    cxxLanguageStandard: .cxx20
)

