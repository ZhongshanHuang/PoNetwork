// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PoNetwork",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PoNetwork",
            targets: ["PoNetwork"]),
    ],
    dependencies: [
            .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMinor(from: "5.10.2"))
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PoNetwork",
            dependencies: ["Alamofire"],
            swiftSettings: [
                            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                            .enableUpcomingFeature("ExistentialAny"),
                            .enableExperimentalFeature("StrictConcurrency=complete"),
                            .enableUpcomingFeature("InternalImportsByDefault"),
                            .enableUpcomingFeature("AccessLevelOnImport"),
                            .enableUpcomingFeature("MemberImportVisibility"),
                        ]
        ),
        .testTarget(
            name: "PoNetworkTests",
            dependencies: ["PoNetwork"]
        ),
    ]
)
