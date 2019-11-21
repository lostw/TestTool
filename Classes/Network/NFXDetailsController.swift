//
//  NFXDetailsController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//
#if TestTool
import Foundation

class NFXDetailsController: WKZScrollController {
    var selectedModel: NFXHTTPModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "网络详情"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "curl", style: .plain, target: self, action: #selector(NFXDetailsController.actionButtonPressed(_:)))

        addDetailsView(self.selectedModel)
    }

    func addDetailsView(_ model: NFXHTTPModel) {
        let requestHeaderContent = getRequestStringFromObject(model)
        let requestHeaderView = PanelView()
        requestHeaderView.titleLabel.text = "Request Header"
        requestHeaderView.contentLabel.attributedText = requestHeaderContent
        contentView.addLinearView(requestHeaderView)

        let requestBodyContent = getRequestBodyStringFooter(model)
        let requestBodyView = PanelView()
        requestBodyView.titleLabel.text = "Request body"
        requestBodyView.contentLabel.text = requestBodyContent
        contentView.addLinearView(requestBodyView)

        if self.selectedModel.shortType as String == HTTPModelShortType.IMAGE.rawValue {
            let reponseBodyContent = getResponseBodyStringFooter(model)
            let reponseBodyView = ImagePanelView()
            reponseBodyView.titleLabel.text = "Response body"
            reponseBodyView.base64Str = reponseBodyContent
            contentView.addLinearView(reponseBodyView)
        } else {
            let reponseBodyContent = getResponseBodyStringFooter(model)
            let reponseBodyView = PanelView()
            reponseBodyView.titleLabel.text = "Response body"
            reponseBodyView.contentLabel.text = reponseBodyContent
            contentView.addLinearView(reponseBodyView)
            if self.selectedModel.shortType as String == HTTPModelShortType.IMAGE.rawValue {
                reponseBodyView.viewButton.isHidden = false
            }
        }

        let responseHeaderContent = getResponseStringFromObject(model)
        let responseHeaderView = PanelView()
        responseHeaderView.titleLabel.text = "Response Header"
        responseHeaderView.contentLabel.attributedText = responseHeaderContent
        contentView.addLinearView(responseHeaderView)
    }

    @objc func actionButtonPressed(_ sender: UIBarButtonItem) {
        if let reqCurl  = self.selectedModel.requestCurl {
            let activityViewController = UIActivityViewController(activityItems: [reqCurl], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.mail, .message, .postToTencentWeibo]
            activityViewController.popoverPresentationController?.barButtonItem = sender
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    func getRequestStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString {
        var tempString: String
        tempString = String()

        tempString += "[\(object.requestMethod!)] \(object.requestURL!)\n"
        if !(object.noResponse) {
            tempString += "[Status] \(object.responseStatus!)\n"
        }
        tempString += "[Request date] \(object.requestDate!)\n"
        if !(object.noResponse) {
            tempString += "[Response date] \(object.responseDate!)\n"
            tempString += "[Time interval] \(object.timeInterval!)\n"
        }
        tempString += "[Timeout] \(object.requestTimeout!)\n"
        tempString += "[Cache policy] \(object.requestCachePolicy!)\n"

        if (object.requestHeaders?.count ?? 0) > 0 {
            for (key, val) in (object.requestHeaders)! {
                tempString += "[\(key)] \(val)\n"
            }
        }

        return formatNFXString(tempString)
    }

    func getRequestBodyStringFooter(_ object: NFXHTTPModel) -> String {
        if object.requestBodyLength == 0 {
            return "Request body is empty\n"
        } else {
            return "\(object.requestBody ?? "")\n"
        }
    }

    func getResponseStringFromObject(_ object: NFXHTTPModel) -> NSAttributedString {
        if object.noResponse {
            return NSAttributedString(string: "No response")
        }

        var tempString: String
        tempString = String()

        if (object.responseHeaders?.count ?? 0) > 0 {
            for (key, val) in object.responseHeaders! {
                tempString += "[\(key)] \(val)\n"
            }
        } else {
            tempString += "Response headers are empty\n"
        }

        return formatNFXString(tempString)
    }

    func getResponseBodyStringFooter(_ object: NFXHTTPModel) -> String {
        if object.responseBodyLength == 0 {
            return "Response body is empty\n"
        } else {
            return "\(object.responseBody ?? "")\n"
        }
    }

    func formatNFXString(_ string: String) -> NSAttributedString {
        var tempMutableString = NSMutableAttributedString()
        tempMutableString = NSMutableAttributedString(string: string)

        let l = string.count

        if let regexKeys = try? NSRegularExpression(pattern: "\\[.+?\\]", options: NSRegularExpression.Options.caseInsensitive) {
            let matchesKeys = regexKeys.matches(in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSRange(location: 0, length: l)) as [NSTextCheckingResult]

            for match in matchesKeys {
                tempMutableString.addAttribute(.foregroundColor, value: NFXColor.NFXBlackColor(), range: match.range)
            }
        }

        return tempMutableString
    }

}

class PanelView: UIView {
    var titleLabel: UILabel!
    var contentLabel: UILabel!
    var viewButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func copyContent() {
        UIPasteboard.general.string = self.contentLabel.text
        self.controller?.view.toast("已复制")
    }

    @objc func viewDetail() {
        if let str = self.contentLabel.text, let data = Data(base64Encoded: str, options: .ignoreUnknownCharacters), let image = UIImage(data: data) {

            let vc = ZZImagePreviewController(photos: [image], currentIndex: 0)
            self.controller?.showController(vc)
        }
    }

    func commonInitView() {
        titleLabel = UILabel()
        titleLabel.zFontSize(15).zColor(UIColor(hex: 0xec5e28))
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
        }

        let copyButton = UIButton()
        copyButton.zText("复制").zColor(UIColor(hex: 0x6798FF)).zFontSize(13)
        copyButton.zBind(target: self, action: #selector(copyContent))
        self.addSubview(copyButton)
        copyButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(titleLabel)
        }

        viewButton = UIButton()
        viewButton.isHidden = true
        viewButton.zText("查看").zColor(UIColor(hex: 0x6798FF)).zFontSize(13)
        viewButton.zBind(target: self, action: #selector(viewDetail))
        self.addSubview(viewButton)
        viewButton.snp.makeConstraints { (make) in
            make.right.equalTo(copyButton.snp.left).offset(-10)
            make.centerY.equalTo(titleLabel)
        }

        contentLabel = UILabel()
        contentLabel.zFontSize(14).zColor(UIColor(hex: 0x888888)).zLines(0)
        contentLabel.text = "没有内容"
        self.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}

class ImagePanelView: UIView {
    var titleLabel: UILabel!
    var imageView: UIImageView!
    var base64Str: String! {
        didSet {
            if let data = Data(base64Encoded: base64Str, options: .ignoreUnknownCharacters) {
                self.imageView.image = UIImage(data: data)!.imageFitTo(width: SCREEN_WIDTH - 20)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func copyContent() {
        UIPasteboard.general.string = self.base64Str
        self.controller?.view.toast("已复制")
    }

    func commonInitView() {
        titleLabel = UILabel()
        titleLabel.zFontSize(15).zColor(UIColor(hex: 0xec5e28))
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
        }

        let copyButton = UIButton()
        copyButton.zText("复制").zColor(UIColor(hex: 0x6798FF)).zFontSize(13)
        copyButton.zBind(target: self, action: #selector(copyContent))
        self.addSubview(copyButton)
        copyButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(titleLabel)
        }

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}
#endif
