// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TaskMaster",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TaskMaster",
            targets: ["TaskMaster"]
        ),
    ],
    targets: [
        .target(
            name: "TaskMaster",
            dependencies: [],
            path: "TaskMaster"
        ),
    ]
)
