// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacLock",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MacLock",
            targets: ["MacLock"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .executableTarget(
            name: "MacLock",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "MacLockTests",
            dependencies: ["MacLock"],
            path: "Tests"
        ),
    ]
)
