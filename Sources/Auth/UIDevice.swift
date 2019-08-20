//
//  UIDevice.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 31/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

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

    var systemVersion: String? { return ProcessInfo.processInfo.operatingSystemVersionString }
    var systemName: String? { return "macOS" }
    var description: String { return "macOS_\(ProcessInfo.processInfo.operatingSystemVersionString)" }

    /// Retrieve an unique token for the current device.
    public static func fetchToken(completionHandler: @escaping (Result<Token, DeviceError>) -> Void ) {
        let uuid = getMacAddress() ?? UUID().uuidString
        Device.token = uuid
        completionHandler(.success(uuid))
    }

    static func findEthernetInterfaces() -> io_iterator_t? {

        let matchingDictUM = IOServiceMatching("IOEthernetInterface")
        // Note that another option here would be:
        // matchingDict = IOBSDMatching("en0");
        // but en0: isn't necessarily the primary interface, especially on systems with multiple Ethernet ports.

        if matchingDictUM == nil {
            return nil
        }

        let matchingDict = matchingDictUM! as NSMutableDictionary
        matchingDict["IOPropertyMatch"] = [ "IOPrimaryInterface": true]

        var matchingServices: io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &matchingServices) != KERN_SUCCESS {
            return nil
        }

        return matchingServices
    }

    // Given an iterator across a set of Ethernet interfaces, return the MAC address of the last one.
    // If no interfaces are found the MAC address is set to an empty string.
    // In this sample the iterator should contain just the primary interface.
    static func getMACAddress(_ intfIterator: io_iterator_t) -> [UInt8]? {

        var macAddress: [UInt8]?

        var intfService = IOIteratorNext(intfIterator)
        while intfService != 0 {

            var controllerService: io_object_t = 0
            if IORegistryEntryGetParentEntry(intfService, kIOServicePlane, &controllerService) == KERN_SUCCESS {

                let dataUM = IORegistryEntryCreateCFProperty(controllerService, "IOMACAddress" as CFString, kCFAllocatorDefault, 0)
                if let dataUM = dataUM {
                    let data = (dataUM.takeRetainedValue() as! CFData) as Data // swiftlint:disable:this force_cast
                    macAddress = [0, 0, 0, 0, 0, 0]
                    data.copyBytes(to: &macAddress!, count: macAddress!.count)
                }
                IOObjectRelease(controllerService)
            }

            IOObjectRelease(intfService)
            intfService = IOIteratorNext(intfIterator)
        }

        return macAddress
    }

    static func getMacAddress() -> String? {
        var macAddressAsString: String?
        if let intfIterator = findEthernetInterfaces() {
            if let macAddress = getMACAddress(intfIterator) {
                macAddressAsString = macAddress.map({ String(format: "%02x", $0) }).joined(separator: ":")
                print(macAddressAsString!)
            }

            IOObjectRelease(intfIterator)
        }
        return macAddressAsString
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
