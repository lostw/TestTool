//
//  TestManager.swift
//  Zhangzhilicai
//
//  Created by william on 20/10/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit
@_exported import LostwKit

extension UserDefaults.Key {
    public static var serverEnv: UserDefaults.Key<Int> { .init(name: "test.env") }
    public static var serverEnvLocal: UserDefaults.Key<String> { .init(name: "test.env.local") }
    public static var h5BaseURLOpen: UserDefaults.Key<Bool> { .init(name: "test.env.h5.isOpen") }
    public static var h5BaseURL: UserDefaults.Key<String> { .init(name: "test.env.h5.baseURL") }

    static var loginAccount: UserDefaults.Key<[[String: String]]> { .init(name: "test.loginAccount") }
}

/// 激活摇一摇
extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            TestManager.shared.start()
        }
    }
}

public class TestManager {
    public static let shared = TestManager()
    var network: NFX
    var isShown = false

    // 登录方法
    public var loginAction: ((String, String, String?) -> Void)?
    // 增加菜单
    var additionMenus: [[TMenu]] = []
    // 扫一扫操作
    public var onResultScanned: ((UIViewController, String) -> Bool)?

    init() {
        self.network = NFX.shared
        self.network.start()
    }

    /// 预置登陆账号
    /// - Parameter accounts: 字典必须含name(账号)、password(密码), 可选desc(描述)
    public func prepareLoginAccounts(_ accounts: [[String: String]]) {
        accounts.forEach {
            if let name = $0["name"] as? String,
                let pwd = $0["password"] as? String {
                let desc = $0["desc"] as? String ?? name
                saveLoginAccount(desc: desc, name: name, pwd: pwd)
            }
        }
    }

    /// 添加额外的菜单，当前支持TEntryMenu(点击)、TToggleMenu(开关切换)
    /// - Parameter menus: 第一层数组表示section, 第二层数组为同section内菜单
    public func installMenus(_ menus: [[TMenu]]) {
        self.additionMenus = menus
    }

    func saveLoginAccount(desc: String, name: String, pwd: String) {
        let info = ["desc": desc, "name": name, "pwd": pwd]

        var accounts = UserDefaults[.loginAccount, []]
        var index: Int?
        for (idx, item) in accounts.enumerated() where item["name"] == name {
            index = idx
            accounts[idx] = info
            break
        }

        if index == nil {
            accounts.append(info)
        }

        UserDefaults[.loginAccount] = accounts
    }

    func start() {
        guard isShown == false else {
            return
        }

        isShown = true
        show()
    }

    func show() {
        let controller = TestMainController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        if var top = UIApplication.shared.keyWindow?.rootViewController {
            while top.presentedViewController != nil {
                top = top.presentedViewController!
            }

            top.present(nav, animated: true, completion: nil)
        }
    }

    func close() {
        isShown = false
    }
}
