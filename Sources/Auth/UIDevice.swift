//
//  UIDevice.swift
//  QMobileAPI
//
//  Created by Eric Marchand on 31/08/2017.
//  Copyright © 2017 Eric Marchand. All rights reserved.
//

import Foundation
import Prephirences

public enum DeviceError: Error {
    case noToken
    case underlying(Error)
}

public struct Device {
    public static let current = Device()

    public var identifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)

        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
}

#if os(macOS)
extension Device {

    var isSimulator: Bool { return false }
    var isSimulatorCase: Bool { return false }

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

    public var realDevice: Device {
        return self
    }

    public var systemVersion: String? { return UIDevice.current.systemVersion }
    public var systemName: String? { return UIDevice.current.systemName}
    public var description: String {
        if isSimulatorCase {
            return "Simulator (\(model.description))"
        }
        return model.description
    }

    enum Model {
        case iPodTouch5
        /// Device is an [iPod touch (6th generation)](https://support.apple.com/kb/SP720)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP720/SP720-ipod-touch-specs-color-sg-2015.jpg)
        case iPodTouch6
        /// Device is an [iPod touch (7th generation)](https://support.apple.com/kb/SP796)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP796/ipod-touch-7th-gen_2x.png)
        case iPodTouch7
        /// Device is an [iPhone 4](https://support.apple.com/kb/SP587)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP643/sp643_iphone4s_color_black.jpg)
        case iPhone4
        /// Device is an [iPhone 4s](https://support.apple.com/kb/SP643)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP643/sp643_iphone4s_color_black.jpg)
        case iPhone4s
        /// Device is an [iPhone 5](https://support.apple.com/kb/SP655)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP655/sp655_iphone5_color.jpg)
        case iPhone5
        /// Device is an [iPhone 5c](https://support.apple.com/kb/SP684)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP684/SP684-color_yellow.jpg)
        case iPhone5c
        /// Device is an [iPhone 5s](https://support.apple.com/kb/SP685)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP685/SP685-color_black.jpg)
        case iPhone5s
        /// Device is an [iPhone 6](https://support.apple.com/kb/SP705)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP705/SP705-iphone_6-mul.png)
        case iPhone6
        /// Device is an [iPhone 6 Plus](https://support.apple.com/kb/SP706)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP706/SP706-iphone_6_plus-mul.png)
        case iPhone6Plus
        /// Device is an [iPhone 6s](https://support.apple.com/kb/SP726)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP726/SP726-iphone6s-gray-select-2015.png)
        case iPhone6s
        /// Device is an [iPhone 6s Plus](https://support.apple.com/kb/SP727)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP727/SP727-iphone6s-plus-gray-select-2015.png)
        case iPhone6sPlus
        /// Device is an [iPhone 7](https://support.apple.com/kb/SP743)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP743/iphone7-black.png)
        case iPhone7
        /// Device is an [iPhone 7 Plus](https://support.apple.com/kb/SP744)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP744/iphone7-plus-black.png)
        case iPhone7Plus
        /// Device is an [iPhone SE](https://support.apple.com/kb/SP738)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP738/SP738.png)
        case iPhoneSE
        /// Device is an [iPhone 8](https://support.apple.com/kb/SP767)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP767/iphone8.png)
        case iPhone8
        /// Device is an [iPhone 8 Plus](https://support.apple.com/kb/SP768)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP768/iphone8plus.png)
        case iPhone8Plus
        /// Device is an [iPhone X](https://support.apple.com/kb/SP770)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP770/iphonex.png)
        case iPhoneX
        /// Device is an [iPhone Xs](https://support.apple.com/kb/SP779)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP779/SP779-iphone-xs.jpg)
        case iPhoneXS
        /// Device is an [iPhone Xs Max](https://support.apple.com/kb/SP780)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP780/SP780-iPhone-Xs-Max.jpg)
        case iPhoneXSMax
        /// Device is an [iPhone Xʀ](https://support.apple.com/kb/SP781)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP781/SP781-iPhone-xr.jpg)
        case iPhoneXR
        /// Device is an [iPhone 11](https://support.apple.com/kb/SP804)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP804/sp804-iphone11_2x.png)
        case iPhone11
        /// Device is an [iPhone 11 Pro](https://support.apple.com/kb/SP805)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP805/sp805-iphone11pro_2x.png)
        case iPhone11Pro
        /// Device is an [iPhone 11 Pro Max](https://support.apple.com/kb/SP806)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP806/sp806-iphone11pro-max_2x.png)
        case iPhone11ProMax
        /// Device is an [iPhone SE (2nd generation)](https://support.apple.com/kb/SP820)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP820/iphone-se-2nd-gen_2x.png)
        case iPhoneSE2
        /// Device is an [iPhone 12](https://support.apple.com/kb/SP830)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP830/sp830-iphone12-ios14_2x.png)
        case iPhone12
        /// Device is an [iPhone 12 mini](https://support.apple.com/kb/SP829)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP829/sp829-iphone12mini-ios14_2x.png)
        case iPhone12Mini
        /// Device is an [iPhone 12 Pro](https://support.apple.com/kb/SP831)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP831/iphone12pro-ios14_2x.png)
        case iPhone12Pro
        /// Device is an [iPhone 12 Pro Max](https://support.apple.com/kb/SP832)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP832/iphone12promax-ios14_2x.png)
        case iPhone12ProMax
        /// Device is an [iPad 2](https://support.apple.com/kb/SP622)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP622/SP622_01-ipad2-mul.png)
        case iPad2
        /// Device is an [iPad (3rd generation)](https://support.apple.com/kb/SP647)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP662/sp662_ipad-4th-gen_color.jpg)
        case iPad3
        /// Device is an [iPad (4th generation)](https://support.apple.com/kb/SP662)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP662/sp662_ipad-4th-gen_color.jpg)
        case iPad4
        /// Device is an [iPad Air](https://support.apple.com/kb/SP692)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP692/SP692-specs_color-mul.png)
        case iPadAir
        /// Device is an [iPad Air 2](https://support.apple.com/kb/SP708)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP708/SP708-space_gray.jpeg)
        case iPadAir2
        /// Device is an [iPad (5th generation)](https://support.apple.com/kb/SP751)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP751/ipad_5th_generation.png)
        case iPad5
        /// Device is an [iPad (6th generation)](https://support.apple.com/kb/SP774)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP774/sp774-ipad-6-gen_2x.png)
        case iPad6
        /// Device is an [iPad Air (3rd generation)](https://support.apple.com/kb/SP787)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP787/ipad-air-2019.jpg)
        case iPadAir3
        /// Device is an [iPad (7th generation)](https://support.apple.com/kb/SP807)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP807/sp807-ipad-7th-gen_2x.png)
        case iPad7
        /// Device is an [iPad (8th generation)](https://support.apple.com/kb/SP822)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP822/sp822-ipad-8gen_2x.png)
        case iPad8
        /// Device is an [iPad Air (4th generation)](https://support.apple.com/kb/SP828)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP828/sp828ipad-air-ipados14-960_2x.png)
        case iPadAir4
        /// Device is an [iPad Mini](https://support.apple.com/kb/SP661)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP661/sp661_ipad_mini_color.jpg)
        case iPadMini
        /// Device is an [iPad Mini 2](https://support.apple.com/kb/SP693)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP693/SP693-specs_color-mul.png)
        case iPadMini2
        /// Device is an [iPad Mini 3](https://support.apple.com/kb/SP709)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP709/SP709-space_gray.jpeg)
        case iPadMini3
        /// Device is an [iPad Mini 4](https://support.apple.com/kb/SP725)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP725/SP725ipad-mini-4.png)
        case iPadMini4
        /// Device is an [iPad Mini (5th generation)](https://support.apple.com/kb/SP788)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP788/ipad-mini-2019.jpg)
        case iPadMini5
        /// Device is an [iPad Pro 9.7-inch](https://support.apple.com/kb/SP739)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP739/SP739.png)
        case iPadPro9Inch
        /// Device is an [iPad Pro 12-inch](https://support.apple.com/kb/SP723)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP723/SP723-iPad_Pro_2x.png)
        case iPadPro12Inch
        /// Device is an [iPad Pro 12-inch (2nd generation)](https://support.apple.com/kb/SP761)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP761/ipad-pro-12in-hero-201706.png)
        case iPadPro12Inch2
        /// Device is an [iPad Pro 10.5-inch](https://support.apple.com/kb/SP762)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP761/ipad-pro-10in-hero-201706.png)
        case iPadPro10Inch
        /// Device is an [iPad Pro 11-inch](https://support.apple.com/kb/SP784)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP784/ipad-pro-11-2018_2x.png)
        case iPadPro11Inch
        /// Device is an [iPad Pro 12.9-inch (3rd generation)](https://support.apple.com/kb/SP785)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP785/ipad-pro-12-2018_2x.png)
        case iPadPro12Inch3
        /// Device is an [iPad Pro 11-inch (2nd generation)](https://support.apple.com/kb/SP814)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP814/ipad-pro-11-2020.jpeg)
        case iPadPro11Inch2
        /// Device is an [iPad Pro 12.9-inch (4th generation)](https://support.apple.com/kb/SP815)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP815/ipad-pro-12-2020.jpeg)
        case iPadPro12Inch4
        /// Device is an [iPad Pro 11-inch (3rd generation)](https://support.apple.com/kb/TODO)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/TODO)
        case iPadPro11Inch3
        /// Device is an [iPad Pro 12.9-inch (5th generation)](https://support.apple.com/kb/TODO)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/TODO)
        case iPadPro12Inch5
        /// Device is a [HomePod](https://support.apple.com/kb/SP773)
        ///
        /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP773/homepod_space_gray_large_2x.jpg)
        case homePod
        indirect case simulator(Model)

        case unknown(String)

        static func from(identifier: String) -> Model {
            switch identifier {
            case "iPod5,1": return .iPodTouch5
            case "iPod7,1": return .iPodTouch6
            case "iPod9,1":  return .iPodTouch7
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return .iPhone4
            case "iPhone4,1":  return .iPhone4s
            case "iPhone5,1", "iPhone5,2":  return .iPhone5
            case "iPhone5,3", "iPhone5,4":  return .iPhone5c
            case "iPhone6,1", "iPhone6,2":  return .iPhone5s
            case "iPhone7,2":  return .iPhone6
            case "iPhone7,1":  return .iPhone6Plus
            case "iPhone8,1":  return .iPhone6s
            case "iPhone8,2":  return .iPhone6sPlus
            case "iPhone9,1", "iPhone9,3":  return .iPhone7
            case "iPhone9,2", "iPhone9,4":  return .iPhone7Plus
            case "iPhone8,4":  return .iPhoneSE
            case "iPhone10,1", "iPhone10,4":  return .iPhone8
            case "iPhone10,2", "iPhone10,5":  return .iPhone8Plus
            case "iPhone10,3", "iPhone10,6":  return .iPhoneX
            case "iPhone11,2":  return .iPhoneXS
            case "iPhone11,4", "iPhone11,6":  return .iPhoneXSMax
            case "iPhone11,8":  return .iPhoneXR
            case "iPhone12,1":  return .iPhone11
            case "iPhone12,3":  return .iPhone11Pro
            case "iPhone12,5":  return .iPhone11ProMax
            case "iPhone12,8":  return .iPhoneSE2
            case "iPhone13,2":  return .iPhone12
            case "iPhone13,1":  return .iPhone12Mini
            case "iPhone13,3":  return .iPhone12Pro
            case "iPhone13,4":  return .iPhone12ProMax
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":  return .iPad2
            case "iPad3,1", "iPad3,2", "iPad3,3":  return .iPad3
            case "iPad3,4", "iPad3,5", "iPad3,6":  return .iPad4
            case "iPad4,1", "iPad4,2", "iPad4,3":  return .iPadAir
            case "iPad5,3", "iPad5,4":  return .iPadAir2
            case "iPad6,11", "iPad6,12":  return .iPad5
            case "iPad7,5", "iPad7,6":  return .iPad6
            case "iPad11,3", "iPad11,4":  return .iPadAir3
            case "iPad7,11", "iPad7,12":  return .iPad7
            case "iPad11,6", "iPad11,7":  return .iPad8
            case "iPad13,1", "iPad13,2":  return .iPadAir4
            case "iPad2,5", "iPad2,6", "iPad2,7":  return .iPadMini
            case "iPad4,4", "iPad4,5", "iPad4,6":  return .iPadMini2
            case "iPad4,7", "iPad4,8", "iPad4,9":  return .iPadMini3
            case "iPad5,1", "iPad5,2":  return .iPadMini4
            case "iPad11,1", "iPad11,2":  return .iPadMini5
            case "iPad6,3", "iPad6,4":  return .iPadPro9Inch
            case "iPad6,7", "iPad6,8":  return .iPadPro12Inch
            case "iPad7,1", "iPad7,2":  return .iPadPro12Inch2
            case "iPad7,3", "iPad7,4":  return .iPadPro10Inch
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":  return .iPadPro11Inch
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":  return .iPadPro12Inch3
            case "iPad8,9", "iPad8,10":  return .iPadPro11Inch2
            case "iPad8,11", "iPad8,12":  return .iPadPro12Inch4
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return .iPadPro11Inch3
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":  return .iPadPro12Inch5
            case "AudioAccessory1,1": return .homePod
            case "i386", "x86_64", "arm64": return .simulator(Model.from(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))
            default: return .unknown(identifier)
            }
        }

        public var description: String {
            switch self {
            case .iPodTouch5: return "iPod touch (5th generation)"
            case .iPodTouch6: return "iPod touch (6th generation)"
            case .iPodTouch7: return "iPod touch (7th generation)"
            case .iPhone4: return "iPhone 4"
            case .iPhone4s: return "iPhone 4s"
            case .iPhone5: return "iPhone 5"
            case .iPhone5c: return "iPhone 5c"
            case .iPhone5s: return "iPhone 5s"
            case .iPhone6: return "iPhone 6"
            case .iPhone6Plus: return "iPhone 6 Plus"
            case .iPhone6s: return "iPhone 6s"
            case .iPhone6sPlus: return "iPhone 6s Plus"
            case .iPhone7: return "iPhone 7"
            case .iPhone7Plus: return "iPhone 7 Plus"
            case .iPhoneSE: return "iPhone SE"
            case .iPhone8: return "iPhone 8"
            case .iPhone8Plus: return "iPhone 8 Plus"
            case .iPhoneX: return "iPhone X"
            case .iPhoneXS: return "iPhone Xs"
            case .iPhoneXSMax: return "iPhone Xs Max"
            case .iPhoneXR: return "iPhone Xʀ"
            case .iPhone11: return "iPhone 11"
            case .iPhone11Pro: return "iPhone 11 Pro"
            case .iPhone11ProMax: return "iPhone 11 Pro Max"
            case .iPhoneSE2: return "iPhone SE (2nd generation)"
            case .iPhone12: return "iPhone 12"
            case .iPhone12Mini: return "iPhone 12 mini"
            case .iPhone12Pro: return "iPhone 12 Pro"
            case .iPhone12ProMax: return "iPhone 12 Pro Max"
            case .iPad2: return "iPad 2"
            case .iPad3: return "iPad (3rd generation)"
            case .iPad4: return "iPad (4th generation)"
            case .iPadAir: return "iPad Air"
            case .iPadAir2: return "iPad Air 2"
            case .iPad5: return "iPad (5th generation)"
            case .iPad6: return "iPad (6th generation)"
            case .iPadAir3: return "iPad Air (3rd generation)"
            case .iPad7: return "iPad (7th generation)"
            case .iPad8: return "iPad (8th generation)"
            case .iPadAir4: return "iPad Air (4th generation)"
            case .iPadMini: return "iPad Mini"
            case .iPadMini2: return "iPad Mini 2"
            case .iPadMini3: return "iPad Mini 3"
            case .iPadMini4: return "iPad Mini 4"
            case .iPadMini5: return "iPad Mini (5th generation)"
            case .iPadPro9Inch: return "iPad Pro (9.7-inch)"
            case .iPadPro12Inch: return "iPad Pro (12.9-inch)"
            case .iPadPro12Inch2: return "iPad Pro (12.9-inch) (2nd generation)"
            case .iPadPro10Inch: return "iPad Pro (10.5-inch)"
            case .iPadPro11Inch: return "iPad Pro (11-inch)"
            case .iPadPro12Inch3: return "iPad Pro (12.9-inch) (3rd generation)"
            case .iPadPro11Inch2: return "iPad Pro (11-inch) (2nd generation)"
            case .iPadPro12Inch4: return "iPad Pro (12.9-inch) (4th generation)"
            case .iPadPro11Inch3: return "iPad Pro (11-inch) (3rd generation)"
            case .iPadPro12Inch5: return "iPad Pro (12.9-inch) (5th generation)"
            case .homePod: return "HomePod"
            case .simulator(let model): return "Simulator (\(model.description))"
            case .unknown(let identifier):  return identifier
            }
        }
    }

    var model: Model {
        return Model.from(identifier: self.identifier)
    }

    /// `true` if device is an isPad.
    public var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    /// `true` if device is an simulator.
    public var isSimulatorCase: Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }

    /// `true` if device is a jailbroken one.
    public static var isJailBroken: Bool = {
        if Device.current.isSimulatorCase {
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

extension Device {
    /// Alias for Device token.
    public typealias Token = String

    /// Device token value. Filled by token
    private static var _token: Token?
    public private(set) static var token: Token? {
        get {
            if _token == nil {
                let keyChain = KeychainPreferences.sharedInstance
                _token = keyChain.string(forKey: "deviceToken")
                if _token == nil {
                    let semaphore = DispatchSemaphore(value: 0)
                    fetchToken { result in
                        _token = try? result.get()
                        semaphore.signal()
                    }
                    semaphore.wait()
                }
            }
            return _token
        }
        set {
            _token = newValue
            let keyChain = KeychainPreferences.sharedInstance
            keyChain["deviceToken"] = newValue
        }
    }

    /// Retrieve an unique token for the current device.
    public static func fetchToken(completionHandler: @escaping (Result<Token, DeviceError>) -> Void ) {
        let completionHandler: ((Result<Token, DeviceError>) -> Void ) = { result in
            Device.token = try? result.get() // register token if success.
            completionHandler(result)
        }

        if #available(iOS 11, *) {
            /*let service = DCAppAttestService.shared
            if service.isSupported {
                service.generateKey { data, error in
                    if let error = error {
                        completionHandler(.failure(DeviceError.underlying(error)))
                    } else if let data = data {
                        let token = data
                        completionHandler(.success(token))
                    } else {
                        assertionFailure("No data or error when getting device token")
                        completionHandler(.failure(.noToken))
                    }
                }
            }*/

            let current = DCDevice.current
            if current.isSupported && !Device.current.isSimulatorCase {
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
        let device = UIDevice.current
        if let uuid = device.simulatorID ?? device.identifierForVendor?.uuidString {
            completionHandler(.success(uuid))
        } else {
            completionHandler(.failure(.noToken))
        }
    }

}

extension UIDevice {

    /// If simualtor return the id from env var SIMULATOR_UDID
    public var simulatorID: String? {
        let env = ProcessInfo().environment
        if let name = env["SIMULATOR_UDID"] {
            return name
        }
        if let name = env["XPC_SIMULATOR_LAUNCHD_NAME"], let id = name.split(separator: ".").last {
            return String(id)
        }
        if let name = env["SIMULATOR_LOG_ROOT"], let id = name.split(separator: "/").last {
            return String(id)
        }
        return nil
    }
}

fileprivate extension Data {
    var deviceToken: String {
        return base64EncodedString()
        // let tokenParts = self.map { data in String(format: "%02.2hhx", data) }
        // return tokenParts.joined()
    }
}

#endif
