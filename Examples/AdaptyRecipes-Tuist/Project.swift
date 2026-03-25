import ProjectDescription

let project = Project(
    name: "AdaptyRecipes-Tuist",
    organizationName: "Adapty",
    options: .options(
        defaultKnownRegions: ["en"],
        developmentRegion: "en",
        disableBundleAccessors: true,
        disableSynthesizedResourceAccessors: true
    ),
    targets: [
        .target(
            name: "AdaptyRecipes-Tuist",
            destinations: .iOS,
            product: .app,
            bundleId: "com.adapty.adaptyuidemoapp",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "1.0.0",
                "CFBundleVersion": "1",
                "UILaunchStoryboardName": "",
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait",
                ],
            ]),
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "Adapty"),
                .external(name: "AdaptyUI"),
            ]
        ),
    ]
)
