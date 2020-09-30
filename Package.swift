// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Adapty",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "Adapty",
            targets: ["Adapty"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .exact("1.3.2")),
    ],
    targets: [
        .target(
            name: "Adapty",
            dependencies: [
                "CryptoSwift"
            ],
            path: "Adapty"
        ),
    ]
)
