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

    public var loginAction: ((String, String) -> Void)?

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
