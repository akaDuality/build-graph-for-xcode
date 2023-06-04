// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UI",
    platforms: [.macOS("11.3")],
    products: [
        .library(
            name: "UI",
            targets: [
                "Details",
                "Filters",
                "Projects",
            ]),
    ],
    dependencies: [
        .package(path: "./../Domain"),
        .package(path: "./../XCLogParser"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.10.3"),
    ],
    targets: [
        .target(
            name: "Details",
            dependencies: [
                "Domain",
//                .product(name: "BuildParser", package: "Domain"),
//                .product(name: "GraphParser", package: "Domain"),
                "XCLogParser",
            ]),
        .testTarget(
            name: "DetailsTests",
            dependencies: [
                "Details",
                .product(name: "Snapshot", package: "Domain"),
                .product(name: "CustomDump", package: "swift-custom-dump", condition: nil),
            ]),
        
        .target(
            name: "Filters",
            dependencies: [
                "Domain",
            ]),
        .testTarget(
            name: "FiltersTests",
            dependencies: [
                "Filters",
            ]),
    
        .target(
            name: "Projects",
            dependencies: [
                "Domain",
            ]),
        .testTarget(
            name: "ProjectsTests",
            dependencies: [
                "Projects",
            ]),
    ]
)
