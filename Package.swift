// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QMobileAPI",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12)
    ],
    products: [
        .library(name: "QMobileAPI", targets: ["QMobileAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .revision("HEAD")),
        .package(url: "https://github.com/Moya/Moya.git", .revision("HEAD")),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger.git", from: "7.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/phimage/Prephirences.git", .revision("HEAD")),
        .package(url: "https://github.com/devicekit/DeviceKit.git", from: "2.1.0")
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
            path: "Sources"),
        .testTarget(
            name: "QMobileAPITests",
            dependencies: ["QMobileAPI"],
            path: "Tests")
    ]
)
