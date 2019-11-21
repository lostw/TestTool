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
    let userList = [
//        ["name":"方方", "phone": "13575708467", "password": "810170"],
        ["name": "唐某忠", "phone": "13107722005", "password": "123456"],
        ["name": "某强", "phone": "13858623571", "password": "123456abc"],
        ["name": "郑某宇", "phone": "15705768766", "password": "123456"],
        ["name": "某波", "phone": "15990694658", "password": "123456"],
        ["name": "赵某鲜", "phone": "15136428082", "password": "123456"],
        ["name": "张某迪", "phone": "15058647577", "password": "123456"]
    ]

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

    @objc func showNetworkLog() {
        self.showController(NFXListController())
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "网络日志", style: .plain, target: self, action: #selector(showNetworkLog))

        let loginLabel = UILabel()
        loginLabel.zFontSize(14).zColor(Theme.shared.text).zLines(0).zAlign(.center)
        loginLabel.text = "v\(APP_VERSION)(\(APP_BUILD))\niOS\(UIDevice.current.systemVersion) \(UIDevice.getNFXDeviceType())"
        loginLabel.zLinearLayout.margin = [4, 0, 4, 0]
        loginLabel.zLinearLayout.justifyContent = .center
        contentView.addLinearView(loginLabel)

        var menu = [[TEntryMenu]]()
        if TestManager.shared.loginAction != nil {
            menu.append([TEntryMenu(title: "测试账号管理") { vc in
                vc.showController(AccountListController())
                }])

            let loginArea = self.buildLoginItemView()
            contentView.addLinearView(loginArea)
        }


        menu.append([
            TEntryMenu(title: "查看日志") { vc in
                vc.showController(LogListController())
            },
            TEntryMenu(title: "配置服务器") {
                $0.showController(TServerSettingController())
            },
            TEntryMenu(title: "打开系统配置") { _ in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            },
            TEntryMenu(title: "扫一扫") {
                $0.showController(ScanViewController())
            },
            TEntryMenu(title: "清除浏览器缓存") { [unowned self] _ in
                self.clearWebCache()
            },
            TEntryMenu(title: "查看缓存文件") { [unowned self] _ in
                self.showController(CacheFilesListController())
            }
        ])

        for list in menu {
            for (idx, item) in list.enumerated() {
                let row = ZZInfoRow.menuRow(title: item.title)
                row.zLinearLayout.height = .containerHeight
                if idx == 0 {
                    row.zLinearLayout.margin.top = 12
                }
                contentView.addLinearView(row)
                row.onTouch { [unowned self] _ in
                    item.onTouch(self)
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
                TestManager.shared.loginAction!(item["name"]!, item["pwd"]!)
//                global.user.logout()
//                self.view.loading()
//                TZAppApi.shared.send(name: TZApiPath.login, parameters: ["phone": item["phone"]!, "loginPassword": item["password"]!, "macType": "2", "type": "2"]).done {
//                    UserCenter.shared.didLogin(phone: item["phone"]!, dict: $0)
//                    self.view.toast("成功登录\(item["name"]!)")
//                }.catch {
//                    self.view.toast($0.localizedDescription)
//                }.finally {
//                   self.view.hideLoading()
//                }
            })
        }

        return view
    }

    func setupMenu() {
//        let dict = [
//            "预约挂号": ["order": 0, "code": "config-url://http-module?identifier=appointment", "img": "/_nuxt/img/icon_yuyue22@2x.6f5e9a6.png", "groupId": "40b363215c674093969c38e776161d99"],
//            "在线缴费": ["order": 2, "code": "config-url://native?identifier=clinic&authLevel=4", "img": "/_nuxt/img/icon_zaixian@2x.f4663b0.png", "groupId": "40b363215c674093969c38e776161d99"],
//            "住院助手": ["order": 4, "code": "config-url://http-module?identifier=hospitalization&authLevel=4&cardMessage=%E6%B7%BB%E5%8A%A0%E4%BD%8F%E9%99%A2%E6%89%80%E7%94%A8%E7%9A%84%E5%B0%B1%E8%AF%8A%E5%8D%A1%EF%BC%8C%E5%8D%B3%E5%8F%AF%E6%9F%A5%E7%9C%8B%E4%BD%8F%E9%99%A2%E4%BF%A1%E6%81%AF", "img": "/_nuxt/img/icon_aa@2x.d948bc4.png", "groupId": "40b363215c674093969c38e776161d99"],
//            "报告查询": ["order": 6, "code": "config-url://http-module?identifier=report&authLevel=2", "img": "/_nuxt/img/icon_baogao@2x.6df0812.png", "groupId": "40b363215c674093969c38e776161d99"],
//            "名医馆": ["order": 8, "code": "config-url://http-module?identifier=famousDoctor&authLevel=1", "img": "/_nuxt/img/icon_baogao@2x.6df0812.png", "groupId": "40b363215c674093969c38e776161d99"],
//            "互联网医院": ["order": 10, "code": "config-url-native://i-hospital?identifier=zxwz&authLevel=2", "img": "/_nuxt/img/icon_baogao@2x.6df0812.png", "groupId": "40b363215c674093969c38e776161d99"],
//
//            "电子就诊卡": ["order": 2, "code": "config-url://http-module?identifier=patientCard&authLevel=4", "img": "/_nuxt/img/icon_yunzeng@2x.924c1d3.png", "groupId": "59d93a6e521d4e9799d3301fde9cc154"],
//            "先诊疗后付费": ["order": 0, "code": "config-url://http-module?identifier=credit&authLevel=4", "img": "/_nuxt/img/icon_xianzenghoufu@2x.03fd102.png", "groupId": "59d93a6e521d4e9799d3301fde9cc154"],
//            "智能导诊": ["order": 6, "code": "config-url://http-module?identifier=diagnosis", "img": "/_nuxt/img/icon_zhineng@2x.57916a2.png", "groupId": "59d93a6e521d4e9799d3301fde9cc154"],
//            "电子票据": ["order": 8, "code": "config-url://http-module?identifier=invoice&authLevel=4", "img": "/_nuxt/img/icon_dianzi@2x.03c9426.png", "groupId": "59d93a6e521d4e9799d3301fde9cc154"],
//            "居家护理": ["order": 10, "code": "config-url://third?appid=7864A7EA7912EA0BE0500B0A0B615ECB&authLevel=1&url=aHR0cHM6Ly9pb3MuZW56ZW1lZC5jb20vSGNhcmVBcHAvb2F1dGh0ei5hc3B4&appname=%E5%B1%85%E5%AE%B6%E6%8A%A4%E7%90%86", "groupId": "59d93a6e521d4e9799d3301fde9cc154"],
//
//            "健康档案": ["order": 0, "code": "config-url://http-module?identifier=choosePatient&authLevel=1&extra=anVtcFRvUGF0aD1oZWFsdGhQcm9maWxlLXZlcmlmeQ", "img": "/_nuxt/img/icon_jiankang@2x.a67aa82.png"],
//            "预防接种": ["order": 2, "code": "config-url://http-buildin?identifier=inoculation&authLevel=1", "img": "/_nuxt/img/icon_yufang@2x.8d72de1.png"],
//            "母子健康手册": ["order": 4, "code": "config-url://http-buildin?identifier=MCHPlatform&authLevel=1", "img": "/_nuxt/img/icon_woman.bd2c05f.png"],
//
//            "商保理赔": ["order": 4, "code": "config-url://http-buildin?identifier=insurance&authLevel=3", "img": "/_nuxt/img/icon_xianzeng@2x.532f01c.png", "groupId": "4ded8715515744e9b111283b28327412"],
//            "孕产服务": ["order": 12, "code": "config-url://http-module?identifier=maternity&authLevel=2", "groupId": "4ded8715515744e9b111283b28327412"],
//        ]
//
//        let arr = ["预约挂号", "报告查询", "先诊疗后付费", "名医馆", "健康档案", "母子健康手册", "预防接种"]

//        _ = ApiClient.management.send(name: "api/app/module/getall", parameters: ["pageSize": 100]).done {
//            let list = $0["list"] as! [[String: Any]]
//            for item in list {
//                let name = item["name"] as! String
//                if let config = dict[name], let mid = item["id"] as? String {
//                    var param = config
//                    param["id"] = mid
//                    param["name"] = name
//                    if let img = (param["img"] as? String) {
//                    param["img"] = "https://w.jktz.gov.cn" + img
//                    }
//                    if let idx = arr.firstIndex(of: name) {
//                        print(name + "=======" + String(idx))
//
//                        param["firstPage"] = "0"
//                        param["indexOrder"] = idx
//                    } else {
//                         print(name + "=======++++++")
//                        param["firstPage"] = "1"
//                        param["flag"] = "测试"
//                    }
//
//                    _ = ApiClient.simple.send(name: "api/app/module/update", parameters: param)
//
//                }
//
//            }
//        }
//
//        _ = ApiClient.management.send(name: "api/app/modulegroup/update", parameters: ["id": "4ded8715515744e9b111283b28327412", "order": 10])
    }
}

#endif
