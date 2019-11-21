//
//  NFXHTTPModelManager.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//
#if TestTool
import Foundation

private let _sharedInstance = NFXHTTPModelManager()

final class NFXHTTPModelManager {
    static let shared = NFXHTTPModelManager()
    fileprivate var models = [NFXHTTPModel]()
    fileprivate var filters = Set<HTTPModelShortType>()
    private let syncQueue = DispatchQueue(label: "NFXSyncQueue")

    func add(_ obj: NFXHTTPModel) {
        syncQueue.async {
            self.models.insert(obj, at: 0)
            NotificationCenter.default.post(name: NSNotification.Name.NFXAddedModel, object: obj)
        }
    }

    func clear() {
        syncQueue.async {
            self.models.removeAll()
        }
    }

    func getModels() -> [NFXHTTPModel] {
        return self.models.filter {
            for type in self.filters where type.rawValue == $0.shortType {
                return false
            }

            return true
        }
    }

    func addFilter(_ filter: HTTPModelShortType) {
        self.filters.insert(filter)
    }

    func getCachedFilters() -> Set<HTTPModelShortType> {
        return self.filters
    }
}
#endif
