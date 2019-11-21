//
//  NFX.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if TestTool
import Foundation
import UIKit

typealias NFXColor = UIColor
typealias NFXFont = UIFont
typealias NFXImage = UIImage
typealias NFXViewController = UIViewController

open class NFX {
    static let shared = NFX()

    fileprivate var started: Bool = false
    var enabled: Bool = false
    fileprivate var ignoredURLs = [String]()

    fileprivate var lastVisitDate: Date = Date()
    internal var cacheStoragePolicy = URLCache.StoragePolicy.notAllowed

    @objc open func start() {
        guard !self.started else {
            showMessage("Already started!")
            return
        }

        self.started = true
        register()
        enabled = true
        clearOldData()
        showMessage("Started!")
    }

    @objc open func stop() {
        unregister()
        enabled = false
        clearOldData()
        self.started = false
        showMessage("Stopped!")
    }

    fileprivate func showMessage(_ msg: String) {
        print("netfox \(msg)")
    }

    fileprivate func register() {
        URLProtocol.registerClass(NFXProtocol.self)
        URLSessionConfiguration.implementNetfox()
    }

    fileprivate func unregister() {
        URLProtocol.unregisterClass(NFXProtocol.self)
    }

    @objc open func setCachePolicy(_ policy: URLCache.StoragePolicy) {
        cacheStoragePolicy = policy
    }

    @objc open func ignoreURL(_ url: String) {
        self.ignoredURLs.append(url)
    }

    internal func getLastVisitDate() -> Date {
        return self.lastVisitDate
    }

    internal func clearOldData() {
        NFXHTTPModelManager.shared.clear()
        do {
            let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!
            let filePathsArray = try FileManager.default.subpathsOfDirectory(atPath: documentsPath)
            for filePath in filePathsArray {
                if filePath.hasPrefix("nfx") {
                    try FileManager.default.removeItem(atPath: (documentsPath as NSString).appendingPathComponent(filePath))
                }
            }

            try FileManager.default.removeItem(atPath: NFXPath.SessionLog)
        } catch {}
    }

    func getIgnoredURLs() -> [String] {
        return self.ignoredURLs
    }
}

#endif
