//
//  HTTPClient.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/8.
//

import Foundation

class HTTPClient {
//    static let shared = HTTPClient()
    fileprivate var urlSession: URLSession!
    fileprivate var sessionConfiguration: URLSessionConfiguration!
    init() {
        sessionConfiguration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: sessionConfiguration)
    }

    func setAdditionalHeaders(_ headers: Dictionary<String, AnyObject>) {
        sessionConfiguration.httpAdditionalHeaders = headers
    }

    func post(url: URL, headers: [String: String], parameters: [String: Any], callback:@escaping (_ data: Data?, _ error: NSError?, _ resCode: Int?) -> Void) {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        guard let postData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            let statusError = NSError(domain:"Request parameters Error", code:-1, userInfo:[NSLocalizedDescriptionKey: "请求参数错误"])
            DispatchQueue.main.async {
                callback(nil, statusError, -1)
            }
            return
        }
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let responseError = error {
                DispatchQueue.main.async {
                    callback(nil, responseError as NSError?, -1)
                }
                print("HTTP request Error: \(responseError)")
            } else if let httpResponse = response as? HTTPURLResponse {
                let resCode = httpResponse.statusCode
                print("HTTP Status Code: \(resCode)")
                if resCode != 200 {
                    let statusError = NSError(domain:"Response Error", code:resCode, userInfo:[NSLocalizedDescriptionKey: "HTTP status code: \(resCode)"])
                    DispatchQueue.main.async {
                        callback(nil, statusError, resCode)
                    }
                } else {
                    DispatchQueue.main.async {
                        callback(data, nil, 200)
                    }
                }
            }else {
                let statusError = NSError(domain:"Response Error", code:-1, userInfo:[NSLocalizedDescriptionKey: "响应失败"])
                DispatchQueue.main.async {
                    callback(nil, statusError, -1)
                }
                print("HTTP request Failure: \(statusError)")
            }
        }
        task.resume()
    }

}
