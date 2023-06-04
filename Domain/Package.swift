// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
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

    ],
    targets: [
        .target(
            name: "BuildParser",
            dependencies: []),
        .testTarget(
            name: "BuildParserTests",
            dependencies: ["BuildParser"]),
        
        .target(
            name: "GraphParser",
            dependencies: []),
        .testTarget(
            name: "GraphParserTests",
            dependencies: ["GraphParser"]),
        
        .target(
            name: "Snapshot",
            dependencies: []),
        .testTarget(
            name: "SnapshotTests",
            dependencies: ["Snapshot"]),
    ]
)
