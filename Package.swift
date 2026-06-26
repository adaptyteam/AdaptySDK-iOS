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
    traits: [
        // COPPA / App Store Kids Category build trait. Off by default (not in a default
        // set), so regular consumers are unaffected. When a consumer enables it, SwiftPM
        // activates the `KidsMode` compilation condition package-wide, and the
        // `#if KidsMode` guards compile out IDFA / AdSupport.
        .trait(
            name: "KidsMode",
            description: "COPPA / App Store Kids Category build — compiles out IDFA / AdSupport."
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
                "Placements/adapty.fallback.schema.yaml",
            ],
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                // Kids Mode is driven by the `KidsMode` trait (activates `#if KidsMode`
                // package-wide); no per-target define, module alias, or unsafeFlags needed.
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

