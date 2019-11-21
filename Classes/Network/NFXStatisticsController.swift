//
//  NFXStatisticsController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//
#if TestTool
import Foundation

class NFXStatisticsController: WKZScrollController {
    var totalModels: Int = 0

    var successfulRequests: Int = 0
    var failedRequests: Int = 0

    var totalRequestSize: Int = 0
    var totalResponseSize: Int = 0

    var totalResponseTime: Float = 0

    var fastestResponseTime: Float = 999
    var slowestResponseTime: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "数据统计"

        generateStatics()
        self.showStatistics()
    }

    override func commonInitView() {
        super.commonInitView()
    }

    func showStatistics() {
        var list = [[String: String]]()

        list.append(["title": "Total requests", "value": String(self.totalModels)])
        list.append(["title": "Successful requests", "value": String(self.successfulRequests)])
        list.append(["title": "Failed requests", "value": String(self.failedRequests)])
        list.append(["title": "Total request size", "value": storageSizeDesc(UInt(self.totalRequestSize))])
        list.append(["title": "Total response size", "value": storageSizeDesc(UInt(self.totalResponseSize))])
        if self.totalModels > 0 {
            list.append(["title": "Fastest response time", "value": String(self.fastestResponseTime) + "s"])
            list.append(["title": "Slowest response time", "value": String(self.slowestResponseTime) + "s"])
        }

        for dict in list {
            let row = ZZInfoRow()
            row.titleLabel.text = dict["title"]
            row.valueLabel.text = dict["value"]
            row.valueLabel.textAlignment = .right
            row.zLinearLayout.height = .containerHeight
            contentView.addLinearView(row)
        }
    }

    func generateStatics() {
        let models = NFXHTTPModelManager.shared.getModels()
        totalModels = models.count

        for model in models {

            if model.isSuccess {
                successfulRequests += 1
            } else {
                failedRequests += 1
            }

            if model.requestBodyLength != nil {
                totalRequestSize += model.requestBodyLength!
            }

            if model.responseBodyLength != nil {
                totalResponseSize += model.responseBodyLength!
            }

            if model.timeInterval != nil {
                totalResponseTime += model.timeInterval!

                if (model.timeInterval ?? 0) < self.fastestResponseTime {
                    self.fastestResponseTime = model.timeInterval!
                }

                if (model.timeInterval ?? 0) > self.slowestResponseTime {
                    self.slowestResponseTime = model.timeInterval!
                }
            }

        }
    }

    func clearStatistics() {
        self.totalModels = 0
        self.successfulRequests = 0
        self.failedRequests = 0
        self.totalRequestSize = 0
        self.totalResponseSize = 0
        self.totalResponseTime = 0
        self.fastestResponseTime = 999
        self.slowestResponseTime = 0
    }
}
#endif
