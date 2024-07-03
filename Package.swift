// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Adapty",

    platforms: [
        .iOS("12.2"),
        .macOS("10.14.4"),
        .visionOS(.v1),
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
            name: "AdaptyCrossPlatformCommon",
            targets: ["AdaptyCrossPlatformCommon"]
        ),
    ],
    targets: [
        .target(
            name: "Adapty",
            dependencies: [],
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "AdaptyUI",
            dependencies: ["Adapty"],
            path: "AdaptyUI",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "AdaptyUITesting",
            dependencies: ["Adapty", "AdaptyUI"],
            path: "AdaptyUITesting"
        ),
        .target(
            name: "AdaptyCrossPlatformCommon",
            dependencies: ["Adapty"],
            path: "CrossPlatformCommon"
        ),
        .testTarget(
            name: "AdaptyTests",
            dependencies: ["Adapty"],
            path: "Tests"
        ),
    ]
)



