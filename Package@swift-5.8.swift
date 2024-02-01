// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "Adapty",

    platforms: [
        .iOS(.v12),
        .macOS("10.14.4")
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
