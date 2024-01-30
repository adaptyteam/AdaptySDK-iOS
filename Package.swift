// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Adapty",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_12),
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
            path: "Sources"
        ),
        .testTarget(
            name: "AdaptyTests",
            dependencies: ["Adapty"],
            path: "Tests"
        )
    ]
)
