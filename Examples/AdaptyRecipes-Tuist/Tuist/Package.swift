// swift-tools-version: 5.9
@preconcurrency import PackageDescription

#if TUIST
    @preconcurrency import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "Adapty": .framework,
            "AdaptyUI": .framework,
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
