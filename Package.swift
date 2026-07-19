// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ccda-kit",
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
    targets: [
        .target(
            name: "CCDAEngine",
            path: "apple/Sources/CCDAEngine"
        ),
        .target(
            name: "CCDAUI",
            dependencies: ["CCDAEngine"],
            path: "apple/Sources/CCDAUI"
        ),
        .testTarget(
            name: "CCDAEngineTests",
            dependencies: ["CCDAEngine"],
            path: "apple/Tests/CCDAEngineTests"
        ),
        .testTarget(
            name: "CCDAUITests",
            dependencies: ["CCDAEngine", "CCDAUI"],
            path: "apple/Tests/CCDAUITests"
        )
    ]
)
