// swift-tools-version: 5.9
@preconcurrency import PackageDescription

#if TUIST
    @preconcurrency import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "Adapty": .framework,
            "AdaptyUI": .framework,
        ],
        targetSettings: [
            "Adapty": .init().swiftVersion("6"),
            "AdaptyUI": .init().swiftVersion("6"),
        ]
    )
#endif

let package = Package(
    name: "AdaptyRecipes-Tuist",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    dependencies: [
        .package(path: "../../../"),
    ]
)
