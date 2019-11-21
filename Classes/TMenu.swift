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
    var onTouch: (UIViewController) -> Void
}

public struct TToggleMenu: TMenu {
    public var title: String
    var onToggle: (Bool) -> Void
}
