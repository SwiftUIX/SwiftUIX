// swift-tools-version:5.8

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
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"])
            ]
        ),
        .target(
            name: "SwiftUIX",
            dependencies: [
                "_SwiftUIX"
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-enable-library-evolution",
                    "-Xfrontend",
                    "-disable-typo-correction",
                    "-Xfrontend",
                    "-disable-verify-exclusivity",
                ])
            ]
        )
    ]
)
