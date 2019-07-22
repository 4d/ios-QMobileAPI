// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QMobileAPI",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v9)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "QMobileAPI",
            targets: ["QMobileAPI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git" , from: "4.8.2"),
        .package(url: "https://github.com/Moya/Moya.git" , from: "13.0.1"),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger.git" , from: "7.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git" , from: "5.0.0"),
        .package(url: "https://github.com/antitypical/Result.git" , from: "4.1.0"),
        .package(url: "https://github.com/phimage/Prephirences.git" , .revision("HEAD"))
        // .package(url: "https://github.com/Eubb/Prephirences.git" , from: "5.0.1") // Not master repo

//        .package(url: "https://github.com/devicekit/DeviceKit.git" , .revision("89452446badb4391899e989b8ae99c84488457f5")), // not for macOS

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "QMobileAPI",
            dependencies: [
                "Alamofire",
                "Moya",
                "XCGLogger",
                "SwiftyJSON",
                "Result",
                "Prephirences"
            ],
            path: "Sources"),
        .testTarget(
            name: "QMobileAPITests",
            dependencies: ["QMobileAPI"],
            path: "Tests")
    ]
)
