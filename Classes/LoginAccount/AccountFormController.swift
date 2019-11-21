//
//  AccountFormController.swift
//  Alamofire
//
//  Created by William on 2019/11/20.
//

import UIKit
import LostwKit

class AccountFormController: WKZScrollController {
    let descRow = ZZInputRow()
    let nameRow = ZZInputRow()
    let passwordRow = ZZInputRow()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc func submit() {
        guard let desc = descRow.field.text, !desc.isEmpty else {
            view.toast("请输入描述")
            return
        }

        guard let name = nameRow.field.text, !name.isEmpty else {
            view.toast("请输入账号")
            return
        }

        guard let pwd = passwordRow.field.text, !pwd.isEmpty else {
           view.toast("请输入账号")
           return
        }

        TestManager.shared.saveLoginAccount(desc: desc, name: name, pwd: pwd)
        self.view.toast("加入成功")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navBack()
        }
    }

    override func commonInitView() {
        super.commonInitView()

        contentView.enableSeperatorLine = true

        descRow.titleLabel.text = "描述"
        descRow.zLinearLayout.height = .containerHeight
        contentView.addLinearView(descRow)

        nameRow.titleLabel.text = "账号"
        nameRow.zLinearLayout.height = .containerHeight
        contentView.addLinearView(nameRow)

        passwordRow.titleLabel.text = "密码"
        passwordRow.zLinearLayout.height = .containerHeight
        contentView.addLinearView(passwordRow)

        let submitButton = UIButton.primary()
        submitButton.zText("提交").zBind(target: self, action: #selector(submit))
        submitButton.zLinearLayout.height = 50
        submitButton.zLinearLayout.margin = [20, 10, 10, 10]
        contentView.addLinearView(submitButton)
    }
}
