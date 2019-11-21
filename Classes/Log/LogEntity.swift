//
//  LogEntity.swift
//  PullDemo
//
//  Created by william on 13/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import Foundation
#if TestTool
class LogEntity {
    var level: String = "Info"
    var fileLine: Int = 0
    var fileName: String?
    var date: Date!
    var payload: String!
    var isExpand: Bool = false
    var tag: String?
    var tagColor: UIColor?
}
#endif
