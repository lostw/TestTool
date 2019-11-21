//
//  TMenu.swift
//  Alamofire
//
//  Created by William on 2019/11/13.
//

import UIKit

public protocol TMenu {
    var title: String {get set}
}

public struct TEntryMenu: TMenu {
    public var title: String
    public var onTouch: (UIViewController) -> Void

    public init(title: String, onTouch: @escaping (UIViewController) -> Void) {
        self.title = title
        self.onTouch = onTouch
    }
}

public struct TToggleMenu: TMenu {
    public var title: String
    public var key: UserDefaults.Key<Bool>
    public var onToggle: ((Bool) -> Void)?

    public init(title: String, key: UserDefaults.Key<Bool>, onToggle: ((Bool) -> Void)?) {
        self.title = title
        self.key = key
        self.onToggle = onToggle
    }
}
