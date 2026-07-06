// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TopNotch",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "TopNotchCore", targets: ["TopNotchCore"]),
        .executable(name: "TopNotch", targets: ["TopNotch"])
    ],
    targets: [
        .target(
            name: "TopNotchCore",
            path: "Sources/TopNotchCore"
        ),
        .executableTarget(
            name: "TopNotch",
            dependencies: ["TopNotchCore"],
            path: "Sources/TopNotch"
        ),
        .testTarget(
            name: "TopNotchTests",
            dependencies: ["TopNotchCore"],
            path: "Tests/Unit"
        )
    ]
)
