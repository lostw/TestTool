//
//  SettingViewController.swift
//  Alamofire
//
//  Created by William on 2019/11/21.
//

import UIKit
import LostwKit

class SettingViewController: WKZScrollController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        debugPrint(NFXHTTPModelManager.shared.getCachedFilters())
    }

    override func commonInitView() {
        super.commonInitView()

        contentView.enableSeperatorLine = true

        HTTPModelShortType.allValues.forEach { model in
            let row = ZZToggleRow()
            row.titleLabel.text = model.rawValue
            row.zLinearLayout.height = .containerHeight
            contentView.addLinearView(row)

            row.switcher.isOn = !NFXHTTPModelManager.shared.getCachedFilters().contains(model)
            row.onToggle = { isOn in
                if isOn {
                    NFXHTTPModelManager.shared.filters.remove(model)
                } else {
                    NFXHTTPModelManager.shared.filters.insert(model)
                }
            }
        }

        var menus = [TMenu]()
        if TestManager.shared.loginAction != nil {
            menus.append(TEntryMenu(title: "测试账号管理") { vc in
                vc.showController(AccountListController())
            })
        }

        menus += [
            TEntryMenu(title: "打开系统配置") { _ in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            },
            TEntryMenu(title: "查看缓存文件") { [unowned self] _ in
                self.showController(CacheFilesListController())
            }
        ]

        for (idx, item) in menus.enumerated() {
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
