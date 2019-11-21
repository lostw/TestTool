//
//  LogTableCell.swift
//  PullDemo
//
//  Created by william on 13/11/2017.
//Copyright © 2017 william. All rights reserved.
//

import UIKit
import SnapKit
#if TestTool
class LogTableCell: WKZTableCell {
    var typeView: UIView!
    var dateLabel: UILabel!
    var messageLabel: UILabel!
    var fileLabel: UILabel!
    var tagLabel: WKZLabel!
    var moreLabel: UILabel!

    override func commonInitView() {
        super.commonInitView()

        typeView = UIView()
        contentView.addSubview(typeView)
        typeView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(8)
        }

        self.dateLabel = UILabel()
        self.dateLabel.textColor = UIColor(hex: 0x888888)
        self.dateLabel.font = UIFont.systemFont(ofSize: 11)
        self.contentView.addSubview(self.dateLabel)
        self.dateLabel.snp.makeConstraints({ make in
            make.centerY.equalTo(typeView)
            make.left.equalTo(typeView.snp.right).offset(4)
        })

        tagLabel = WKZLabel()
        tagLabel.padding = [2, 8]
        tagLabel.layer.cornerRadius = 10
        tagLabel.layer.backgroundColor = UIColor(hex: 0x1A82D1).cgColor
        tagLabel.textColor = .white
        tagLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints({ make in
            make.top.equalTo(typeView)
            make.right.equalToSuperview().offset(-12)
        })

        self.messageLabel = UILabel()
        self.messageLabel.font = UIFont.systemFont(ofSize: 14)
        self.messageLabel.textColor = UIColor(hex: 0x3b3b3b)
        self.messageLabel.numberOfLines = 0
        self.contentView.addSubview(self.messageLabel)
        self.messageLabel.snp.makeConstraints({ make in
            make.top.equalTo(self.typeView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        })

        self.fileLabel = UILabel()
        self.fileLabel.textColor = UIColor(hex: 0x888888)
        self.fileLabel.font = UIFont.systemFont(ofSize: 10)
        self.contentView.addSubview(self.fileLabel)
        self.fileLabel.snp.makeConstraints({ make in
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-8)
        })

        moreLabel = UILabel()
        moreLabel.text = "more"
        moreLabel.textColor = UIColor(hex: 0x6798FF)
        moreLabel.font = UIFont.systemFont(ofSize: 11)
        self.contentView.addSubview(self.moreLabel)
        moreLabel.snp.makeConstraints({ make in
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-8)
        })
    }

    //不用调用super.bindData
    override func bindData(_ data: Any, indexPath: IndexPath) {
        if let model = data as? LogEntity {
            if model.level == "Info" {
                typeView.backgroundColor = UIColor(hex: 0x5bc0de)
            } else {
                typeView.backgroundColor = UIColor(hex: 0xf0ad4e)
            }
            self.dateLabel.text = model.date.format(.datetime)
            if let tag = model.tag {
                tagLabel.isHidden = false
                tagLabel.text = tag
                tagLabel.layer.backgroundColor = (model.tagColor ?? UIColor(hex: 0x1A82D1)).cgColor
            } else {
                tagLabel.isHidden = true
            }

            if model.payload.count > 300 && !model.isExpand {
                self.messageLabel.text = String(model.payload[0, 300]) + "..."
                moreLabel.isHidden = false
            } else {
                self.messageLabel.text = model.payload
                moreLabel.isHidden = true
            }

            self.fileLabel.text = "\(model.fileName!): \(model.fileLine)"
        }
    }
}
#endif
