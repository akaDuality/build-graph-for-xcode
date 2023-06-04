// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.macOS("11.3")],
    products: [
        .library(
            name: "Domain",
            targets: [
                "BuildParser",
                "GraphParser",
            ]),
        .library(
            name: "BuildParser",
            targets: ["BuildParser"]),
        .library(
            name: "GraphParser",
            targets: ["GraphParser"]),
        .library(
            name: "Snapshot",
            targets: ["Snapshot"]),
    ],
    dependencies: [
        .package(path: "./../XCLogParser"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.10.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.11.0"),
    ],
    targets: [
        .target(
            name: "BuildParser",
            dependencies: [
                "GraphParser",
                "XCLogParser",
            ]),
        .testTarget(
            name: "BuildParserTests",
            dependencies: [
                "BuildParser",
                "Snapshot",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: nil),
            ]),
        .target(
            name: "GraphParser"
        ),
        .testTarget(
            name: "GraphParserTests",
            dependencies: [
                "GraphParser",
                .product(name: "CustomDump", package: "swift-custom-dump", condition: nil),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: nil),
            ]),
        
        .target(
            name: "Snapshot",
            resources: [
                .copy("Samples/IncrementalWithBigGap.bgbuildsnapshot"),
                .copy("Samples/PrepareBuildOnly.bgbuildsnapshot"),
                .copy("Samples/SimpleClean.bgbuildsnapshot"),
                .copy("Samples/Xcode14.3.bgbuildsnapshot")
            ]
        ),
        .testTarget(
            name: "SnapshotTests",
            dependencies: ["Snapshot"]),
    ]
)
