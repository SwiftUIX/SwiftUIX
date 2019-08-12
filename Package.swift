// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftUIX",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "SwiftUIX", targets: ["SwiftUIX"])
    ],
    targets: [
        .target(name: "SwiftUIX", dependencies: [], path: "Sources"),
        .testTarget(name: "SwiftUIXTests", dependencies: ["SwiftUIX"], path: "Tests")
    ],
    swiftLanguageVersions: [
        .version("5.1")
    ]
)
