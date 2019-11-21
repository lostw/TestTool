//
//  NFXHelper.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

import Foundation
#if TestTool

import UIKit

public enum HTTPModelShortType: String {
    case JSON = "JSON"
    case XML = "XML"
    case HTML = "HTML"
    case IMAGE = "Image"
    case OTHER = "Other"

    static let allValues = [JSON, XML, HTML, IMAGE, OTHER]
}

extension NFXColor {
    class func NFXGreenColor() -> NFXColor {
        return NFXColor(hex: 0x38bb93)
    }

    class func NFXRedColor() -> NFXColor {
        return NFXColor(hex: 0xd34a33)
    }

    class func NFXGray44Color() -> NFXColor {
        return NFXColor(hex: 0x707070)
    }

    class func NFXBlackColor() -> NFXColor {
        return NFXColor(hex: 0x231f20)
    }
}

extension NFXFont {
    class func NFXFont(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size)!
    }

    class func NFXFontBold(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }
}

extension URLRequest {
    func getNFXCachePolicy() -> String {
        switch cachePolicy {
        case .useProtocolCachePolicy: return "UseProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData: return "ReloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData: return "ReloadIgnoringLocalAndRemoteCacheData"
        case .returnCacheDataElseLoad: return "ReturnCacheDataElseLoad"
        case .returnCacheDataDontLoad: return "ReturnCacheDataDontLoad"
        case .reloadRevalidatingCacheData: return "ReloadRevalidatingCacheData"
        @unknown default:
           return "unknown"
        }

    }

    func getNFXHeaders() -> [AnyHashable: Any] {
        return allHTTPHeaderFields ?? [:]
    }

    func getNFXBody() -> Data {
        return httpBodyStream?.readfully() ?? URLProtocol.property(forKey: "NFXBodyData", in: self) as? Data ?? Data()
    }

    func getCurl() -> String {
        guard let url = url else { return "" }
        let baseCommand = "curl \(url.absoluteString)"

        var command = [baseCommand]

        if let method = httpMethod {
            command.append("-X \(method)")
        }

        for (key, value) in getNFXHeaders() {
            command.append("-H \u{22}\(key): \(value)\u{22}")
        }

        if var body = String(data: getNFXBody(), encoding: .utf8) {
            body = body.replacingAll(matching: "\"", with: "\\\"")
            command.append("-d \u{22}\(body)\u{22}")
        }

        return command.joined(separator: " ")
    }
}

extension URLResponse {
    func getNFXStatus() -> Int {
        return (self as? HTTPURLResponse)?.statusCode ?? 999
    }

    func getNFXHeaders() -> [AnyHashable: Any] {
        return (self as? HTTPURLResponse)?.allHeaderFields ?? [:]
    }
}

extension InputStream {
  func readfully() -> Data {
    var result = Data()
    var buffer = [UInt8](repeating: 0, count: 4096)

    open()

    var amount = 0
    repeat {
      amount = read(&buffer, maxLength: buffer.count)
      if amount > 0 {
        result.append(buffer, count: amount)
      }
    } while amount > 0

    close()

    return result
  }
}

extension Date {
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            return true
        } else {
            return false
        }
    }
}

struct NFXPath {
    static let Documents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first! as NSString

    static let SessionLog = NFXPath.Documents.appendingPathComponent("session.log")
}

extension String {
    func appendToFile(filePath: String) {
        let contentToAppend = self

        if let fileHandle = FileHandle(forWritingAtPath: filePath) {
            /* Append to file */
            fileHandle.seekToEndOfFile()
            fileHandle.write(contentToAppend.data(using: String.Encoding.utf8)!)
        } else {
            /* Create new file */
            do {
                try contentToAppend.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error creating \(filePath)")
            }
        }
    }
}

@objc extension URLSessionConfiguration {
    private static var firstOccurrence = true

    static func implementNetfox() {
        guard firstOccurrence else { return }
        firstOccurrence = false

        // First let's make sure setter: URLSessionConfiguration.protocolClasses is de-duped
        // This ensures NFXProtocol won't be added twice
        swizzleProtocolSetter()

        // Now, let's make sure NFXProtocol is always included in the default configuration(s)
        // Adding it twice won't be an issue anymore, because we've de-duped the setter
        swizzleDefault()
    }

    private static func swizzleProtocolSetter() {
        let instance = URLSessionConfiguration.default

        let aClass: AnyClass = object_getClass(instance)!

        let origSelector = #selector(setter: URLSessionConfiguration.protocolClasses)
        let newSelector = #selector(setter: URLSessionConfiguration.protocolClasses_Swizzled)

        let origMethod = class_getInstanceMethod(aClass, origSelector)!
        let newMethod = class_getInstanceMethod(aClass, newSelector)!

        method_exchangeImplementations(origMethod, newMethod)
    }

    private var protocolClasses_Swizzled: [AnyClass]? {
        get {
            // Unused, but required for compiler
            return self.protocolClasses_Swizzled
        }
        set {
            guard let newTypes = newValue else { self.protocolClasses_Swizzled = nil; return }

            var types = [AnyClass]()

            // de-dup
            for newType in newTypes {
                if !types.contains(where: { (existingType) -> Bool in
                    existingType == newType
                }) {
                    types.append(newType)
                }
            }

            self.protocolClasses_Swizzled = types
        }
    }

    private static func swizzleDefault() {
        let aClass: AnyClass = object_getClass(self)!

        let origSelector = #selector(getter: URLSessionConfiguration.default)
        let newSelector = #selector(getter: URLSessionConfiguration.default_swizzled)

        let origMethod = class_getClassMethod(aClass, origSelector)!
        let newMethod = class_getClassMethod(aClass, newSelector)!

        method_exchangeImplementations(origMethod, newMethod)
    }

    private class var default_swizzled: URLSessionConfiguration {
            let config = URLSessionConfiguration.default_swizzled

            // Let's go ahead and add in NFXProtocol, since it's safe to do so.
            config.protocolClasses?.insert(NFXProtocol.self, at: 0)

            return config
    }
}

public extension NSNotification.Name {
    static let NFXDeactivateSearch = Notification.Name("NFXDeactivateSearch")
    static let NFXReloadData = Notification.Name("NFXReloadData")
    static let NFXAddedModel = Notification.Name("NFXAddedModel")
}

public extension UIDevice {

    class func getNFXDeviceType() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""

        for child in mirror.children {
            if let value = child.value as? Int8, value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }

        return parseDeviceType(identifier)
    }

    // swiftlint:disable cyclomatic_complexity
    class func parseDeviceType(_ identifier: String) -> String {
        // swiftlint:enable cyclomatic_complexity
        if identifier == "i386" || identifier == "x86_64" {
            return "Simulator"
        }

        switch identifier {
        case "iPhone1,1": return "iPhone 2G"
        case "iPhone1,2": return "iPhone 3G"
        case "iPhone2,1": return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "IPhone 4"
        case "iPhone4,1": return "iPhone 4S"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5C"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5S"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone8,1": return "iPhone 6S Plus"
        case "iPhone8,2": return "iPhone 6S"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"

        case "iPod1,1": return "iPodTouch 1G"
        case "iPod2,1": return "iPodTouch 2G"
        case "iPod3,1": return "iPodTouch 3G"
        case "iPod4,1": return "iPodTouch 4G"
        case "iPod5,1": return "iPodTouch 5G"
        case "iPod7,1": return "iPodTouch 6G"

        case "iPad1,1", "iPad1,2": return "iPad"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini Retina"
        case "iPad4,7", "iPad4,8": return "iPad Mini 3"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad6,3", "iPad6,4": return "iPad Pro 9.7-inch"
        case "iPad6,7", "iPad6,8": return "iPad Pro 12.9-inch"
        case "iPad6,11", "iPad6,12": return "iPad 5"
        case "iPad7,1", "iPad7,2": return "iPad Pro 12.9-inch"
        case "iPad7,3", "iPad7,4": return "iPad Pro 10.5-inch"

        default: return "Not Available"
        }
    }
}
#endif
