// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "App",
    defaultLocalization: "en",
    platforms: [.macOS("11.3")],
    products: [
        .library(
            name: "App",
            targets: ["App"]),
    ],
    dependencies: [
        .package(path: "./../UI"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "UI"
            ]),
    ]
)
