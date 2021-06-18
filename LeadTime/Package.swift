// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LeadTime",
    products: [
        .library(
            name: "LeadTime",
            targets: ["LeadTime"]),
    ],
    dependencies: [
        .package(name: "OctoKit",
                 url: "https://github.com/nerdishbynature/octokit.swift",
                 from: "0.11.0"),
    ],
    targets: [
        .target(
            name: "LeadTime",
            dependencies: [
                "OctoKit"
            ]),
        .testTarget(
            name: "LeadTimeTests",
            dependencies: ["LeadTime", "OctoKit"]),
    ]
)
