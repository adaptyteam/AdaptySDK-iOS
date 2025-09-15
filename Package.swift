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
            name: "AdaptyUIBuider",
            dependencies: [],
            path: "Sources.UIBuilder"
        ),
        .target(
            name: "Adapty",
            dependencies: ["AdaptyUIBuider"],
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target( // deprecated
            name: "AdaptyUI",
            dependencies: ["AdaptyUIBuider", "Adapty"],
            path: "Deprecated.AdaptyUI",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "AdaptyUITesting",
            dependencies: ["AdaptyUIBuider", "Adapty", "AdaptyUI"],
            path: "Sources.UIBuilderTools"
        ),
        .target(
            name: "AdaptyPlugin",
            dependencies: ["AdaptyUIBuider", "Adapty", "AdaptyUI"],
            path: "Sources.AdaptyPlugin"
        ),
        .testTarget(
            name: "AdaptyTests",
            dependencies: ["AdaptyUIBuider", "Adapty"],
            path: "Tests",
            resources: [
                .process("Placements/fallback.json"),
                .process("Placements/fallback_large.json"),
            ]
        ),
    ]
)
