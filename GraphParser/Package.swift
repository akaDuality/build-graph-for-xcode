// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphParser",
    products: [
        .library(
            name: "GraphParser",
            targets: ["GraphParser"]),
    ],
    dependencies: [
        .package(name: "Interface", path: "Interface"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing",
                 from: "1.9.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "GraphParser",
            dependencies: ["Interface"]),
        .testTarget(
            name: "GraphParserTests",
            dependencies: [
                "GraphParser",
                .product(name: "SnapshotTesting",
                         package: "swift-snapshot-testing",
                         condition: nil),
                .product(name: "CustomDump",
                         package: "swift-custom-dump",
                         condition: nil)
            ],
            resources: [
                .process("targetGraph.txt")
            ]
        )
    ]
)
