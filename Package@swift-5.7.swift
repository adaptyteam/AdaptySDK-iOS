// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Adapty",

    platforms: [
        .iOS("12.2"),
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
