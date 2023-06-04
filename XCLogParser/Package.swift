// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCLogParser",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(name: "XCLogParser", targets: ["XCLogParser"])
    ],
    dependencies: [
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.1.0"),
    ],
    targets: [
        .target(
            name: "XCLogParser",
            dependencies: ["Gzip"]
        ),
        .testTarget(
            name: "XCLogParserTests",
            dependencies: ["XCLogParser"]
        ),
    ]
)
