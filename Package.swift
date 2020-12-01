// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QMobileAPI",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
        .library(name: "QMobileAPI", targets: ["QMobileAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .revision("5.0.0")),
        .package(url: "https://github.com/Moya/Moya.git", .revision("14.0.0")),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger.git", from: "7.0.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/phimage/Prephirences.git", from: "5.1.0"),
        .package(url: "https://github.com/phimage/DeviceKit.git", .branch("feature/macos"))
    ],
    targets: [
        .target(
            name: "QMobileAPI",
            dependencies: [
                "Alamofire",
                "Moya",
                "XCGLogger",
                "SwiftyJSON",
                "Prephirences",
                "DeviceKit"
            ],
            path: "Sources",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "QMobileAPITests",
            dependencies: ["QMobileAPI"],
            path: "Tests")
    ],
    swiftLanguageVersions: [.v5]
)
