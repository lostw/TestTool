//
//  TServerSettingController.swift
//  HealthTaiZhou
//
//  Created by William on 2019/8/5.
//  Copyright © 2019 Wonders. All rights reserved.
//

import UIKit

class TServerSettingController: WKZScrollController {
    var serverRow: ZZPickerRow!
    lazy var localRow: ZZInputRow = {
        let row = ZZInputRow()
        row.titleLabel.text = "本地环境"
        row.zLinearLayout.height = .containerHeight
        row.field.text = UserDefaults[.serverEnvLocal]
        return row
    }()
    var h5ServerRow: ZZInputRow!
    var h5OpenRow: ZZToggleRow!
    var paymentRow: ZZToggleRow!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "服务器配置"
        self.isObserveKeyboard = true
    }

    @objc func submit() {
        self.view.endEditing(true)

        let isOn = h5OpenRow.switcher.isOn
        var text = self.h5ServerRow.field.text ?? ""
        let envIndex = serverRow.selectedIndex
        let local = self.localRow.field.text ?? ""

        if envIndex == 3 {
            if !local.starts(with: "http") {
                self.view.toast("请输入正确的本地地址")
                return
            }
        }

        if !text.isEmpty {
            if !text.starts(with: "http") {
                self.view.toast("请输入正确的地址")
                return
            }
        }

        UserDefaults[.serverEnv] = envIndex
        UserDefaults[.h5BaseURLOpen] = isOn
        UserDefaults[.h5BaseURL] = text
        UserDefaults[.serverEnvLocal] = local

        self.alert(message: "接口环境切换需要重启app") { _ in
            exit(0)
        }
    }

    override func commonInitView() {
        super.commonInitView()
        contentView.enableSeperatorLine = true
        contentView.viewHeight = 50

        serverRow = ZZPickerRow()
        serverRow.titleLabel.text = "接口环境"
        serverRow.valueLabel.textAlignment = .right
        serverRow.options = ["测试", "准生产", "生产", "本地"]
        serverRow.onValueChange = { [unowned self] (idx, value) -> String? in
            if idx == 3 {
                self.contentView.insertLinearView(self.localRow, after: self.serverRow)
            } else {
                self.contentView.removeLinearView(self.localRow)
            }
            return value
        }
        serverRow.zLinearLayout.height = .containerHeight
        contentView.addLinearView(serverRow)
        serverRow.selectedIndex = UserDefaults[.serverEnv, 0]
        serverRow.valueLabel.text = serverRow.options[serverRow.selectedIndex]
        if serverRow.selectedIndex == 3 {
            contentView.addLinearView(localRow)
        }

        h5OpenRow = ZZToggleRow()
        h5OpenRow.titleLabel.text = "是否启用h5域"
        h5OpenRow.switcher.isOn = UserDefaults[.h5BaseURLOpen, false]
        h5OpenRow.zLinearLayout.margin.top = 12
        h5OpenRow.zLinearLayout.height = .containerHeight
        contentView.addLinearView(h5OpenRow)

        h5ServerRow = ZZInputRow()
        h5ServerRow.titleLabel.text = "h5域"
        h5ServerRow.field.text = UserDefaults[.h5BaseURL]
        h5ServerRow.zLinearLayout.height = .containerHeight
        contentView.addLinearView(h5ServerRow)

        let submitButton = UIButton.primary()
        submitButton.zText("提交").zBind(target: self, action: #selector(submit))
        submitButton.zLinearLayout.height = 44
        submitButton.zLinearLayout.margin = [30, 10, 10, 10]
        contentView.addLinearView(submitButton)
    }
}
