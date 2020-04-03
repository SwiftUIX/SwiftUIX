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
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "SwiftUIX",
            dependencies: [.product(name: "CasePaths", package: "CasePaths")],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [
        .version("5.1")
    ]
)
