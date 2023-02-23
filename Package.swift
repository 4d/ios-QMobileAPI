// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QMobileAPI",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
        .library(name: "QMobileAPI", targets: ["QMobileAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.4"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger.git", from: "7.0.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/phimage/Prephirences.git", from: "5.4.0")
    ],
    targets: [
        .target(
            name: "QMobileAPI",
            dependencies: [
                "Alamofire",
                "Moya",
                "XCGLogger",
                "SwiftyJSON",
                "Prephirences"
            ],
            path: "Sources",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        .testTarget(
            name: "QMobileAPITests",
            dependencies: ["QMobileAPI"],
            path: "Tests")
    ],
    swiftLanguageVersions: [.v5]
)
