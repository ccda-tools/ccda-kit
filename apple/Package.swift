// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ccda-swift",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CCDAEngine",
            targets: ["CCDAEngine"]
        ),
        .library(
            name: "CCDAUI",
            targets: ["CCDAUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            exact: "1.19.3"
        )
    ],
    targets: [
        .target(
            name: "CCDAEngine",
            path: "Sources/CCDAEngine"
        ),
        .target(
            name: "CCDAUI",
            dependencies: ["CCDAEngine"],
            path: "Sources/CCDAUI"
        ),
        .testTarget(
            name: "CCDAEngineTests",
            dependencies: ["CCDAEngine"],
            path: "Tests/CCDAEngineTests"
        ),
        .testTarget(
            name: "CCDAUITests",
            dependencies: [
                "CCDAEngine",
                "CCDAUI",
                .product(
                    name: "SnapshotTesting",
                    package: "swift-snapshot-testing"
                )
            ],
            path: "Tests/CCDAUITests",
            exclude: ["Views/__Snapshots__"]
        )
    ]
)
