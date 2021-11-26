// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildTime",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BuildTime",
            targets: ["BuildTime"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BuildTime",
            dependencies: []),
        .testTarget(
            name: "BuildTimeTests",
            dependencies: [
                "BuildTime",
                .product(name: "CustomDump",
                         package: "swift-custom-dump",
                         condition: nil)
            ],
            resources: [
                .process("buildTimes.csv"),
                .process("buildTimes1_M1.csv"),
                .process("buildTimes2.csv"),
                .process("buildTimes3.csv"),
                .process("buildTimes4.csv"),
            ]
        ),
    ]
)
