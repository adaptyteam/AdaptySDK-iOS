// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Adapty",

    platforms: [
        .iOS("12.2"),
        .macOS("10.14.4"),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "Adapty",
                 targets: ["Adapty"])
    ],
    targets: [
        .target(
            name: "Adapty",
            dependencies: [],
            path: "Sources",
            resources: [ .process("Resources/PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "AdaptyTests",
            dependencies: ["Adapty"],
            path: "Tests"
        )
    ]
)
