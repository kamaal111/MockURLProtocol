// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MockURLProtocol",
    products: [
        .library(
            name: "MockURLProtocol",
            targets: ["MockURLProtocol"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MockURLProtocol",
            dependencies: []
        ),
        .testTarget(
            name: "MockURLProtocolTests",
            dependencies: ["MockURLProtocol"]
        ),
    ]
)
