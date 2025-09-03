// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TabBarView",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TabBarView",
            targets: ["TabBarView"]
        ),
    ],
    dependencies: [
        .package(path: "../FeedView"),
        .package(path: "../FeedListView"),
        .package(path: "../CharacterDetailsView"),
        .package(url: "https://github.com/obadasemary/SUIRouting.git", .upToNextMajor(from: "1.0.6"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TabBarView",
            dependencies: [
                .product(name: "FeedView", package: "FeedView"),
                .product(name: "SUIRouting", package: "SUIRouting"),
                .product(name: "FeedListView", package: "FeedListView"),
                .product(name: "CharacterDetailsView", package: "CharacterDetailsView")
            ]
        ),
        .testTarget(
            name: "TabBarViewTests",
            dependencies: ["TabBarView"]
        ),
    ]
)
