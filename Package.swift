// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FanC",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "FanCCore",
            path: "Sources/FanCCore",
            linkerSettings: [
                .linkedFramework("Metal"),
            ]
        ),
        .executableTarget(
            name: "fanc",
            dependencies: [
                "FanCCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/fanc"
        ),
        .executableTarget(
            name: "FanCApp",
            dependencies: ["FanCCore"],
            path: "Sources/FanCApp"
        ),
        .testTarget(
            name: "FanCTests",
            dependencies: ["FanCCore"],
            path: "Tests/FanCTests"
        ),
    ]
)
