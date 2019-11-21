//
//  LogListController.swift
//  PullDemo
//
//  Created by william on 13/11/2017.
//Copyright © 2017 william. All rights reserved.
//

import UIKit
#if TestTool
class LogListController: WKZListController {
    private let optionDropView = OptionDropView()
    var filePath: URL {
        return files[currentIdx]
    }
    var files: [URL]!
    var currentIdx: Int = 0 {
        didSet {
            self.refresh()
        }
    }
    let dateFormat: DateFormatter = {
        let tmp = DateFormatter()
        tmp.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS xxx"
        return tmp
    }()
    override var forPager: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "日志"

        let url = WKZCache.shared.fileCacheURL().appendingPathComponent("log")
        files = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [])
        files = files.sorted {$0.lastPathComponent > $1.lastPathComponent}

        self.optionDropView.reloadData()
        self.optionDropView.addBottomLine()

        self.registerCell(LogTableCell.self)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        self.sourceHandler = { page, callback in
            var tmp = [String.SubSequence]()
            if let data = try? Data(contentsOf: self.filePath) {
                let text = String(data: data, encoding: .utf8)!
                tmp = text.split(separator: "\n")
            }

            var list = [String]()
            var current: String!
            for i in 0..<tmp.count {
                let str = String(tmp[i])

                if let range = str.range(of: "\\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2}:\\d{2}", options: .regularExpression),
                    range.lowerBound == str.startIndex {
                    if current != nil {
                        list.append(current)
                    }

                    current = str
                } else {
                    current.append("\n")
                    current.append(str)
                }
            }

            if current != nil {
                list.append(current)
            }

            callback(list.reversed(), false)
        }

        self.refresh()

        // Do any additional setup after loading the view.
    }

    override func parseItem(_ item: Any) -> Any? {
        if let text = item as? String {
            let model = LogEntity()

            let infoArr = text.split(separator: "|")
            model.date = self.dateFormat.date(from: infoArr[0].trimmingCharacters(in: .whitespaces))

            model.level = infoArr[1].trimmingCharacters(in: .whitespaces)

            let tmpString = infoArr[3]

            let colonIndex = tmpString.firstIndex(of: ":")!
            let dashIndex = tmpString.firstIndex(of: "-")!
            model.fileName = String(tmpString[..<colonIndex]).trimmingCharacters(in: .whitespaces)

            model.fileLine = Int(String(tmpString[tmpString.index(after: colonIndex)..<dashIndex]).trimmingCharacters(in: .whitespaces)) ?? 0

            let payloadIndex = tmpString.index(dashIndex, offsetBy: 2)
            var payload = String(tmpString[payloadIndex...])

            if let regex = try? Regex(string: "^\\[(.*?)\\]") {
                if let match = regex.firstMatch(in: payload) {
                    let tag = match.captures[0]!
                    let arr = tag.split(separator: ":")
                    model.tag = String(arr[0])
                    if arr.count > 1 {
                        if let colorValue = Int32(String(arr[1]), radix: 16) {
                            model.tagColor = UIColor(hex: colorValue)
                        }
                    }
                    let index = match.range.upperBound
                    payload = String(payload[index...])
                }
            }

            model.payload = payload

            return model
        }

        return super.parseItem(item)
    }

//    override func didSelectItem(_ item: Any, at indexPath: IndexPath) {
//        if let model = item as? LogEntity {
//            UIPasteboard.general.string = model.payload
//        }
//    }

    override func commonInitView() {
        super.commonInitView()

        self.optionDropView.delegate = self
        self.optionDropView.frame = [0, -40, self.view.bounds.width, 40]
        self.tableView.addSubview(self.optionDropView)

        self.tableView.contentInset = [40, 0, 0, 0]
    }

    override func didSelectItem(_ item: Any, at indexPath: IndexPath) {
        let model = item as! LogEntity
        if model.payload.count > 300 {
            model.isExpand = !model.isExpand
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_ :)) {
            return true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

     func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_ :)) {
            if let model = self.list[indexPath.row] as? LogEntity {
                UIPasteboard.general.string = model.payload
            }
        }
    }
}

extension LogListController: OptionDropViewDelegate {
    func numberOfSectionsInDropView(_ view: OptionDropView) -> Int {
        return 1
    }

    func dropView(_ view: OptionDropView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }

    func dropView(_ view: OptionDropView, defaultIndexForSection section: Int) -> Int {
        return currentIdx
    }

    func dropView(_ view: OptionDropView, titleAt indexPath: IndexPath) -> String {
        return self.files[indexPath.row].lastPathComponent
    }

    func dropView(_ view: OptionDropView, selectAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.currentIdx = indexPath.row
        }

    }
}
#endif
