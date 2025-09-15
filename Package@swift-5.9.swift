// swift-tools-version: 5.9
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
            name: "AdaptyUICore",
            targets: ["AdaptyUICore"]
        ),
        .library(
            name: "AdaptyUI",
            targets: ["AdaptyUI"]
        ),
        .library(
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
            name: "Adapty",
            dependencies: ["AdaptyUICore"],
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "AdaptyUICore",
            dependencies: [],
            path: "Sources.AdaptyUICore"
        ),
        .target(
            name: "AdaptyUI",
            dependencies: ["Adapty", "AdaptyUICore"],
            path: "AdaptyUI",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "AdaptyUITesting",
            dependencies: ["Adapty", "AdaptyUICore", "AdaptyUI"],
            path: "AdaptyUITesting"
        ),
        .target(
            name: "AdaptyPlugin",
            dependencies: ["Adapty", "AdaptyUICore", "AdaptyUI"],
            path: "Sources.AdaptyPlugin"
        ),
        .testTarget(
            name: "AdaptyTests",
            dependencies: ["Adapty", "AdaptyUICore"],
            path: "Tests"
        ),
    ]
)
