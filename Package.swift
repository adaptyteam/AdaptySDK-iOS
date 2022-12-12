// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Adapty",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "Adapty",
                 targets: ["Adapty"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Adapty",
            dependencies: [],
            path: "Sources"
        )
    ]
)
