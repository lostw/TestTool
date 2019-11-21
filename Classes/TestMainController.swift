//
//  TestMainController.swift
//  Zhangzhilicai
//
//  Created by william on 20/10/2017.
//Copyright © 2017 william. All rights reserved.
//

import UIKit
import WebKit

#if TestTool
let testHostKey = "test.host"

class TestMainController: WKZScrollController {
    deinit {
        TestManager.shared.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "调试"
        // Do any additional setup after loading the view.
    }

    func showMessage(_ message: String) {
        self.view.toast(message)
    }

    @objc func showSetting() {
        self.showController(SettingViewController())
    }

    func clearWebCache() {
        let set = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().removeData(ofTypes: set, modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: {
            self.showMessage("成功清除浏览器缓存")
        })
    }

    @objc func closeTestController() {
        self.close()
        TestManager.shared.close()
    }

    override func commonInitView() {
        super.commonInitView()

        self.contentView.enableSeperatorLine = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeTestController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "设置", style: .plain, target: self, action: #selector(showSetting))

        let loginLabel = UILabel()
        loginLabel.zFontSize(14).zColor(Theme.shared.text).zLines(0).zAlign(.center)
        loginLabel.text = "v\(APP_VERSION)(\(APP_BUILD))\niOS\(UIDevice.current.systemVersion) \(UIDevice.getNFXDeviceType())"
        loginLabel.zLinearLayout.margin = [4, 0, 4, 0]
        loginLabel.zLinearLayout.justifyContent = .center
        contentView.addLinearView(loginLabel)

        var menus = [[TMenu]]()
        if TestManager.shared.loginAction != nil {
            let loginArea = self.buildLoginItemView()
            contentView.addLinearView(loginArea)
        }

        menus.append([
            TEntryMenu(title: "查看日志") { vc in
                vc.showController(LogListController())
            },
            TEntryMenu(title: "请求记录") { vc in
                 vc.showController(NFXListController())
            },
            TEntryMenu(title: "配置服务器") {
                $0.showController(TServerSettingController())
            },
            TEntryMenu(title: "扫一扫") {
                $0.showController(ScanViewController())
            },
            TEntryMenu(title: "清除浏览器缓存") { [unowned self] _ in
                self.clearWebCache()
            }
        ])

        let menu = TestManager.shared.additionMenus
        if !menu.isEmpty {
            menus += menu
        }

        for list in menus {
            for (idx, item) in list.enumerated() {
                if let item = item as? TEntryMenu {
                    let row = ZZInfoRow.menuRow(title: item.title)
                    row.zLinearLayout.height = .containerHeight
                    if idx == 0 {
                        row.zLinearLayout.margin.top = 12
                    }
                    contentView.addLinearView(row)
                    row.onTouch { [unowned self] _ in
                        item.onTouch(self)
                    }
                } else if let item = item as? TToggleMenu {
                    let row = ZZToggleRow()
                    row.titleLabel.text = item.title
                    row.zLinearLayout.height = .containerHeight
                    if idx == 0 {
                        row.zLinearLayout.margin.top = 12
                    }
                    contentView.addLinearView(row)
                    row.onToggle = { flag in
                        UserDefaults[item.key] = flag
                        item.onToggle?(flag)
                    }
                }

            }
        }
    }

    func buildLoginItemView() -> UIView {
        let userList = UserDefaults[.loginAccount, []]

        let countOfColumn = 3
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.zLinearLayout.height = .manual(60 *
            Double((userList.count - 1) / countOfColumn + 1))

        for (idx, item) in userList.enumerated() {
            let cell = ZZInfoCell()
            cell.titleLabel.text = item["desc"]?.asMaskedName()
            cell.valueLabel.text = item["name"]?.asMaskedMobile()
            cell.titleLabel.font = UIFont.systemFont(ofSize: 16)
            cell.valueLabel.font = UIFont.systemFont(ofSize: 10)
            cell.adjustGap(2)

            cell.titleLabel.snp.updateConstraints({ (make) in
                make.bottom.equalTo(cell.snp.centerY).offset(4)
            })

            view.addSubview(cell)

            let row = idx / countOfColumn
            let column = idx % countOfColumn

            cell.backgroundColor = (row + column) % 2 == 0 ? UIColor.white : UIColor(hex: 0xe0e0e0)

            cell.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(CGFloat(column) * self.view.bounds.width / CGFloat(countOfColumn))
                make.top.equalToSuperview().offset(CGFloat(row) * 60)
                make.width.equalToSuperview().dividedBy(countOfColumn)
                make.height.equalTo(60)
            })
            cell.onTouch({ [unowned self] _ in
                TestManager.shared.loginAction!(item["name"]!, item["pwd"]!, item["desc"])
            })
        }

        return view
    }
}

#endif
