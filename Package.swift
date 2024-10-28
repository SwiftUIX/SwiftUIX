// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "SwiftUIX",
    platforms: [
        .iOS(.v13), 
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftUIX",
            targets: [
                "_SwiftUIX",
                "SwiftUIX"
            ]
        )
    ],
    targets: [
        .target(
            name: "_SwiftUIX",
            dependencies: []
        ),
        .target(
            name: "SwiftUIX",
            dependencies: [
                "_SwiftUIX"
            ]
        ),
        .testTarget(
            name: "SwiftUIXTests",
            dependencies: ["SwiftUIX"],
            path: "Tests"
        )
    ]
)
