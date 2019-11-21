//
//  NFXHTTPModel.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

#if TestTool
import Foundation
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

public class NFXHTTPModel: NSObject {
    private var _randomHash: String?

    @objc public var requestURL: String?
    @objc public var requestMethod: String?
    @objc public var requestCachePolicy: String?
    @objc public var requestDate: Date?
    @objc public var requestTime: String?
    @objc public var requestTimeout: String?
    @objc public var requestHeaders: [AnyHashable: Any]?
    public var requestBodyLength: Int?
    @objc public var requestType: String?
    @objc public var requestCurl: String?

    public var responseStatus: Int?
    @objc public var responseType: String?
    @objc public var responseDate: Date?
    @objc public var responseTime: String?
    @objc public var responseHeaders: [AnyHashable: Any]?
    public var responseBodyLength: Int?

    public var timeInterval: Float?

    public var randomHash: String {
        if _randomHash == nil {
            _randomHash = UUID().uuidString
        }
        return _randomHash!
    }

    @objc public var shortType: String = HTTPModelShortType.OTHER.rawValue

    @objc public var noResponse: Bool = true

    var isSuccess: Bool {
        return self.responseStatus != nil && self.responseStatus < 400
    }

    func saveRequest(_ request: URLRequest) {
        self.requestDate = Date()
        self.requestTime = getTimeFromDate(self.requestDate!)
        self.requestURL =  request.url?.absoluteString ?? "-"
        self.requestMethod = request.httpMethod ?? "-"
        self.requestCachePolicy = request.getNFXCachePolicy()
        self.requestTimeout = String(request.timeoutInterval)
        self.requestHeaders = request.getNFXHeaders()
        self.requestType = requestHeaders?["Content-Type"] as! String?
        self.requestCurl = request.getCurl()
    }

    func saveRequestBody(_ request: URLRequest) {
        saveRequestBodyData(request.getNFXBody())
    }

    func logRequest(_ request: URLRequest) {
        formattedRequestLogEntry().appendToFile(filePath: NFXPath.SessionLog)
    }

    func saveErrorResponse() {
        self.responseDate = Date()
    }

    func saveResponse(_ response: URLResponse, data: Data) {
        self.noResponse = false

        self.responseDate = Date()
        self.responseTime = getTimeFromDate(self.responseDate!)
        self.responseStatus = response.getNFXStatus()
        self.responseHeaders = response.getNFXHeaders()

        let headers = response.getNFXHeaders()

        if let contentType = headers["Content-Type"] as? String {
            self.responseType = contentType.components(separatedBy: ";")[0]
            self.shortType = getShortTypeFrom(self.responseType!).rawValue
        }

        self.timeInterval = Float(self.responseDate!.timeIntervalSince(self.requestDate!))

        saveResponseBodyData(data)
        formattedResponseLogEntry().appendToFile(filePath: NFXPath.SessionLog)
    }

    func saveRequestBodyData(_ data: Data) {
        self.requestBodyLength = data.count

        if let content = String(data: data, encoding: .utf8) {
            saveData(content, toFile: getRequestBodyFilepath())
        }
    }

    func saveResponseBodyData(_ data: Data) {
        var bodyString: String?

        if self.shortType as String == HTTPModelShortType.IMAGE.rawValue {
            bodyString = data.base64EncodedString(options: .endLineWithLineFeed)

        } else {
            if let tempBodyString = String(data: data, encoding: String.Encoding.utf8) {
                bodyString = tempBodyString
            }
        }

        if let content = bodyString {
            self.responseBodyLength = data.count
            saveData(content, toFile: getResponseBodyFilepath())
        }

    }

    fileprivate func prettyOutput(_ rawData: Data, contentType: String? = nil) -> String? {
        if let contentType = contentType {
            let shortType = getShortTypeFrom(contentType)
            if let output = prettyPrint(rawData, type: shortType) {
                return output as String
            }
        }
        return String(data: rawData, encoding: .utf8)
    }

    var responseBody: String? {
        guard let data = readRawData(getResponseBodyFilepath()) else {
            return nil
        }

        return prettyOutput(data, contentType: responseType)
    }

    var requestBody: String? {
        guard let data = readRawData(getRequestBodyFilepath()) else {
            return nil
        }
        return prettyOutput(data, contentType: requestType)
    }

    @objc public func getRequestBodyFilepath() -> String {
        let dir = getDocumentsPath() as NSString
        return dir.appendingPathComponent(getRequestBodyFilename())
    }

    @objc public func getRequestBodyFilename() -> String {
        return"nfx_request_body_\(self.requestTime!)_\(randomHash)"
    }

    @objc public func getResponseBodyFilepath() -> String {
        let dir = getDocumentsPath() as NSString
        return dir.appendingPathComponent(getResponseBodyFilename())
    }

    @objc public func getResponseBodyFilename() -> String {
        return "nfx_response_body_\(self.requestTime!)_\(randomHash)"
    }

    @objc public func getDocumentsPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!
    }

    @objc public func saveData(_ dataString: String, toFile: String) {
        do {
            try dataString.write(toFile: toFile, atomically: false, encoding: .utf8)
        } catch {
            print("catch !!!")
        }
    }

    @objc public func readRawData(_ fromFile: String) -> Data? {
        return (try? Data(contentsOf: URL(fileURLWithPath: fromFile)))
    }

    @objc public func getTimeFromDate(_ date: Date) -> String? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minutes = components.minute else {
            return nil
        }
        if minutes < 10 {
            return "\(hour):0\(minutes)"
        } else {
            return "\(hour):\(minutes)"
        }
    }

    public func getShortTypeFrom(_ contentType: String) -> HTTPModelShortType {
        if NSPredicate(format: "SELF MATCHES %@",
                                "^application/(vnd\\.(.*)\\+)?json$").evaluate(with: contentType) {
            return .JSON
        }

        if (contentType == "application/xml") || (contentType == "text/xml") {
            return .XML
        }

        if contentType == "text/html" {
            return .HTML
        }

        if contentType.hasPrefix("image/") {
            return .IMAGE
        }

        return .OTHER
    }

    public func prettyPrint(_ rawData: Data, type: HTTPModelShortType) -> String? {
        switch type {
        case .JSON:
            do {
                let rawJsonData = try JSONSerialization.jsonObject(with: rawData, options: [])
                let prettyPrintedString = try JSONSerialization.data(withJSONObject: rawJsonData, options: [.prettyPrinted])
                return String(data: prettyPrintedString, encoding: .utf8)
            } catch {
                return nil
            }

        default:
            return nil

        }
    }

    @objc public func formattedRequestLogEntry() -> String {
        var log = String()

        if let requestURL = self.requestURL {
            log.append("-------START REQUEST -  \(requestURL) -------\n")
        }

        if let requestMethod = self.requestMethod {
            log.append("[Request Method] \(requestMethod)\n")
        }

        if let requestDate = self.requestDate {
            log.append("[Request Date] \(requestDate)\n")
        }

        if let requestTime = self.requestTime {
            log.append("[Request Time] \(requestTime)\n")
        }

        if let requestType = self.requestType {
            log.append("[Request Type] \(requestType)\n")
        }

        if let requestTimeout = self.requestTimeout {
            log.append("[Request Timeout] \(requestTimeout)\n")
        }

        if let requestHeaders = self.requestHeaders {
            log.append("[Request Headers]\n\(requestHeaders)\n")
        }

        log.append("[Request Body]\n \(requestBody ?? "")\n")

        if let requestURL = self.requestURL {
            log.append("-------END REQUEST - \(requestURL) -------\n\n")
        }

        return log
    }

    @objc public func formattedResponseLogEntry() -> String {
        var log = String()

        if let requestURL = self.requestURL {
            log.append("-------START RESPONSE -  \(requestURL) -------\n")
        }

        if let responseStatus = self.responseStatus {
            log.append("[Response Status] \(responseStatus)\n")
        }

        if let responseType = self.responseType {
            log.append("[Response Type] \(responseType)\n")
        }

        if let responseDate = self.responseDate {
            log.append("[Response Date] \(responseDate)\n")
        }

        if let responseTime = self.responseTime {
            log.append("[Response Time] \(responseTime)\n")
        }

        if let responseHeaders = self.responseHeaders {
            log.append("[Response Headers]\n\(responseHeaders)\n\n")
        }

        log.append("[Response Body]\n \(responseBody ?? "")\n")

        if let requestURL = self.requestURL {
            log.append("-------END RESPONSE - \(requestURL) -------\n\n")
        }

        return log
    }

}
#endif
