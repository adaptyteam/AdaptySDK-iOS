// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Adapty",

    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "AdaptyLogger",
            targets: ["AdaptyLogger"]
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
            path: "Sources.Logger"
        ),
        .target(
            name: "AdaptyUIBuilder",
            dependencies: ["AdaptyLogger"],
            path: "Sources.UIBuilder",
            exclude: [
                "adaptyui.v4.4.1.schema.yaml"
            ]
        ),
        .target(
            name: "Adapty",
            dependencies: ["AdaptyUIBuilder", "AdaptyLogger"],
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "Adapty_KidsMode",
            dependencies: ["AdaptyUIBuilder", "AdaptyLogger"],
            path: "Sources.KidsMode",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .define("ADAPTY_KIDS_MODE")
            ]
        ),
        .target(
            name: "AdaptyUI",
            dependencies: ["AdaptyUIBuilder", "Adapty", "AdaptyLogger"],
            path: "Sources.AdaptyUI",
            resources: [.copy("PrivacyInfo.xcprivacy")]
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
            path: "Sources.DeveloperTools"
        ),
        .target(
            name: "AdaptyPlugin",
            dependencies: ["AdaptyUIBuilder", "Adapty", "AdaptyUI", "AdaptyLogger"],
            path: "Sources.AdaptyPlugin",
            exclude: [
                "cross_platform.yaml"
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
            dependencies: ["AdaptyUIBuilder", "Adapty", "AdaptyLogger"],
            path: "Tests",
            resources: [
                .process("Placements/fallback.json"),
                .process("Placements/fallback_large.json"),
            ]
        ),
    ]
)
