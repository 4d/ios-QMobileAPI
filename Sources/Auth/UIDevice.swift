//
//  UIDevice.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 31/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Result
import Foundation

public enum DeviceError: Error {
    case noToken
    case underlying(Error)
}

#if os(macOS)
enum Device {
    case mac
    static let current: Device = .mac

    var isSimulator: Bool { return false }

    static let isJailBroken: Bool = false

    var realDevice: Device {
        return self
    }

    public typealias Token = String

    static let token: String? = nil
    var systemVersion: String? { return ProcessInfo.processInfo.operatingSystemVersionString }
    var systemName: String? { return "macOS" }
    var description: String { return "macOS_\(ProcessInfo.processInfo.operatingSystemVersionString)" }

    /// Retrieve an unique token for the current device.
    public static func fetchToken(completionHandler: @escaping (Result<Token, DeviceError>) -> Void ) {
        let uuid = UUID().uuidString
        completionHandler(.success(uuid))
    }
}
#else

import DeviceCheck
import UIKit

extension Device {
    /// Alias for Device token.
    public typealias Token = String

    /// Device token value. Filled by token
    private static var _token: Token?
    public private(set) static var token: Token? {
        get {
            if _token == nil {
                let semaphore = DispatchSemaphore(value: 0)
                fetchToken { result in
                    _token = try? result.get()
                    semaphore.signal()
                }
                semaphore.wait()
            }
            return _token
        }
        set {
            _token = newValue
        }
    }

    /// Retrieve an unique token for the current device.
    public static func fetchToken(completionHandler: @escaping (Result<Token, DeviceError>) -> Void ) {
        let completionHandler: ((Result<Token, DeviceError>) -> Void ) = { result in
            Device.token = try? result.get() // register token if success.
            completionHandler(result)
        }
        if #available(iOS 11, *) {
            let current = DCDevice.current
            if current.isSupported {
                current.generateToken { data, error in
                    if let error = error {
                        completionHandler(.failure(DeviceError.underlying(error)))
                    } else if let data = data {
                        let token = data.deviceToken
                        completionHandler(.success(token))
                    } else {
                        assertionFailure("No data or error when getting device token")
                        completionHandler(.failure(.noToken))
                    }
                }
                return
            }
        }
        // Simulator or old device
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            completionHandler(.success(uuid))
        } else {
            completionHandler(.failure(.noToken))
        }
    }

    public static var isJailBroken: Bool = {
        if Device.current.isSimulator {
            return false
        }
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Applications/Cydia.app")
            || fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
            || fileManager.fileExists(atPath: "/bin/bash")
            || fileManager.fileExists(atPath: "/usr/sbin/sshd")
            || fileManager.fileExists(atPath: "/etc/apt")
            || fileManager.fileExists(atPath: "/private/var/lib/apt/") {
            return true
        }
        if let url = URL(string: "cydia://package/com.example.package"), UIApplication.shared.canOpenURL(url) {
            return true
        }
        // Could check also some path with fopen
        return false
    }()
}

fileprivate extension Data {
    var deviceToken: String {
        return base64EncodedString()
        //let tokenParts = self.map { data in String(format: "%02.2hhx", data) }
        //return tokenParts.joined()
    }
}

import DeviceKit
public typealias Device = DeviceKit.Device

#endif
