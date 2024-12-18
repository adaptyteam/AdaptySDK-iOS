// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Adapty",

    platforms: [
        .iOS(.v13),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Adapty",
            targets: ["Adapty"]
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
            dependencies: [],
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "AdaptyUI",
            dependencies: ["Adapty"],
            path: "AdaptyUI",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "AdaptyUITesting",
            dependencies: ["Adapty", "AdaptyUI"],
            path: "AdaptyUITesting"
        ),
        .target(
            name: "AdaptyPlugin",
            dependencies: ["Adapty", "AdaptyUI"],
            path: "Sources.AdaptyPlugin"
        ),
        .testTarget(
            name: "AdaptyTests",
            dependencies: ["Adapty"],
            path: "Tests"
        ),
    ]
)
