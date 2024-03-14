// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWOnBoardingViewController",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "WWOnBoardingViewController", targets: ["WWOnBoardingViewController"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "WWOnBoardingViewController", resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
