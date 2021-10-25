// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildParser",
    platforms: [.iOS("13.0"), .macOS("10.13")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BuildParser",
            targets: ["BuildParser"]),
    ],
    dependencies: [
        .package(name: "Interface", path: "Interface"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing",
                 from: "1.9.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.2.0"),
        .package(url: "https://github.com/MobileNativeFoundation/XCLogParser", from: "0.2.28")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BuildParser",
            dependencies: [
                "Interface",
                .product(name: "XCLogParser",
                         package: "XCLogParser",
                         condition: nil)
            ]),
        .testTarget(
            name: "BuildParserTests",
            dependencies: [
                "BuildParser",
                .product(name: "SnapshotTesting",
                         package: "swift-snapshot-testing",
                         condition: nil),
                .product(name: "CustomDump",
                         package: "swift-custom-dump",
                         condition: nil),
            ],
            resources: [.process("Samples/AppEvents.json"),
                        .process("Samples/TestEvents.json")]),
    ]
)
