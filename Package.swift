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
            name: "AdaptyUIBuider",
            targets: ["AdaptyUIBuider"]
        ),
        .library( // deprecated
            name: "AdaptyUI",
            targets: ["AdaptyUI"]
        ),
        .library( // need rename to AdaptyUIBuiderTools
            name: "AdaptyUITesting",
            targets: ["AdaptyUITesting"]
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
            path: "Sources.Logger"
        ),
        .target(
            name: "AdaptyUIBuider",
            dependencies: ["AdaptyLogger"],
            path: "Sources.UIBuilder"
        ),
        .target(
            name: "Adapty",
            dependencies: ["AdaptyUIBuider", "AdaptyLogger"],
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target( // deprecated
            name: "AdaptyUI",
            dependencies: ["AdaptyUIBuider", "Adapty", "AdaptyLogger"],
            path: "Deprecated.AdaptyUI",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "AdaptyUITesting",
            dependencies: ["AdaptyUIBuider", "Adapty", "AdaptyUI", "AdaptyLogger"],
            path: "Sources.UIBuilderTools"
        ),
        .target(
            name: "AdaptyPlugin",
            dependencies: ["AdaptyUIBuider", "Adapty", "AdaptyUI", "AdaptyLogger"],
            path: "Sources.AdaptyPlugin"
        ),
        .testTarget(
            name: "AdaptyTests",
            dependencies: ["AdaptyUIBuider", "Adapty", "AdaptyLogger"],
            path: "Tests",
            resources: [
                .process("Placements/fallback.json"),
                .process("Placements/fallback_large.json"),
            ]
        ),
    ]
)
