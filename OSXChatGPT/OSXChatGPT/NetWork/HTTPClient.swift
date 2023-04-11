//
//  HTTPClient.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/8.
//

import Foundation

enum HTTPError: Error {
    case err(message: String)
    var message: String {
        switch self {
        case .err(let er):
            return er
        }
    }
}
struct HTTPResponseError: Decodable {
    let error: HTTPResponseErrorEntity
}

struct HTTPResponseErrorEntity: Decodable {
    let message: String
    let type: String?
}
struct HTTPResponse: Decodable {
    let choices: [HTTPResponseChoice]
    let model: String
}

struct HTTPResponseChoice: Decodable {
    let finishReason: String?
    let delta: HTTPResponseMessage?
    let message: HTTPResponseMessage?
}

struct HTTPResponseMessage: Decodable {
    let content: String?
    let role: String?
}


class HTTPClient {
//    static let shared = HTTPClient()
    fileprivate var urlSession: URLSession!
    fileprivate var sessionConfiguration: URLSessionConfiguration!
    private var isCancelStreamRequest: Bool = false
    private var currentTask: URLSessionTask?
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    init() {
        sessionConfiguration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: sessionConfiguration)
    }

    func setAdditionalHeaders(_ headers: Dictionary<String, AnyObject>) {
        sessionConfiguration.httpAdditionalHeaders = headers
    }
    
    func post(url: URL, headers: [String: String], parameters: [String: Any], callback:@escaping (_ data: Data?, _ error: NSError?, _ resCode: Int?) -> Void) {
        let request = createRequest(url: url, headers: headers, parameters: parameters)
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
    func cancelStream() {
        isCancelStreamRequest = true
        currentTask?.cancel()
    }
    func postStream(chatRequest: ChatGPTRequest) async throws -> AsyncThrowingStream<String, Error> {
        var request = URLRequest(url: chatRequest.url)
        request.allHTTPHeaderFields = chatRequest.headers
        if let postData = try? JSONSerialization.data(withJSONObject: chatRequest.parameters, options: []) {
            request.httpBody = postData
        }
        request.httpMethod = "POST"
        isCancelStreamRequest = false
        let (result, response) = try await urlSession.bytes(for: request)
        currentTask = result.task
        if (isCancelStreamRequest) {
            currentTask?.cancel()
            currentTask = nil;
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.err(message: "Request Error")
        }
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                if (isCancelStreamRequest) {
                    currentTask?.cancel()
                    currentTask = nil;
                }
                errorText += line
            }
            if let data = errorText.data(using: .utf8), let response = try? jsonDecoder.decode(HTTPResponseError.self, from: data).error {
                errorText = "\n\(response.message)"
            }
            throw HTTPError.err(message: "Response Error code:\(httpResponse.statusCode) res:\(errorText)")
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                do {
                    for try await line in result.lines {
                        if isCancelStreamRequest {
                            result.task.cancel()
                        }
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self?.jsonDecoder.decode(HTTPResponse.self, from: data),
                           let text = response.choices.first?.delta?.content
                        {
                            continuation.yield(text)
                        }else if let data = line.data(using: .utf8),
                                    let response = try? self?.jsonDecoder.decode(HTTPResponse.self, from: data),
                                    let text = response.choices.first?.message?.content {
                            continuation.yield(text)
                            
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func createRequest(url: URL, headers: [String: String], parameters: [String: Any]) -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        if let postData = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
            request.httpBody = postData
        }
        request.httpMethod = "POST"
        return request
    }
    
    

}
/// upload
extension HTTPClient {
    static func uploadPrompt(prompt: Prompt) {
        getShaString { sha, err in
            if let shaString = sha {
                uploadPrompt(prompt: prompt, sha: shaString)
            }else {
                print("获取sha失败")
            }
        }
    }
    static func uploadPrompt(prompt: Prompt, sha: String) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let userDate = dateFormatter.string(from: currentDate)
        
        var user = "User"
        if let userName = SystemManager.shared.userName {
            user = userName
        }
        if let version = SystemManager.shared.OSVersion {
            user = user + "OS\(version)_"
        }
        user = user + userDate
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let date = dateFormatter.string(from: currentDate)
        let urlString = "\(githubUrl)/\(user)/\(date)"
        var dict = prompt.dictionaryWithValues(forKeys: ["author", "prompt", "title", "hexColor"])
        dict["idString"] = prompt.idString
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else {
            return
        }
        let base64String = jsonData.base64EncodedString()
        print(base64String)
        let parameters = ["message": user,
                          "content":base64String,
                          "sha":sha] as [String : Any]
        let url = URL(string: urlString)!
    
        var request = URLRequest(url: url)
        let authorizationValue = "Bearer \(ServerManager.shared.uploadDataToken)"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationValue, forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        if let postData = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
            request.httpBody = postData
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("statusCode: \(response.statusCode)")
            }
            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("response: \(responseString ?? "")")
            }
        }
        task.resume()
    }
    
    static func getShaString(callback:@escaping (_ sha: String?, _ err: String?) -> Void) {
        let url = URL(string: githubUrl)!
        var request = URLRequest(url: url)
        let authorizationValue = "Bearer \(ServerManager.shared.uploadDataToken)"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationValue, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                callback(nil, error.localizedDescription)
                return
            }
            var code = 0
            if let response = response as? HTTPURLResponse {
                code = response.statusCode
            }
            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("response1: \(responseString ?? "")")
                if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                   let sha = json[0]["sha"] as? String {
                    callback(sha, nil)
                }else {
                    callback(nil, "response error code:\(code)")
                }
            }else {
                callback(nil, "data error code:\(code)")
            }
        }
        task.resume()
    }
    
    static func getPrompt(callback:@escaping (_ datas: [Any], _ err: String?) -> Void) {
        let url = URL(string: githubGetUrl)!
        var request = URLRequest(url: url)
        let authorizationValue = "Bearer \(ServerManager.shared.getDataToken)"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationValue, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                callback([], error.localizedDescription)
                return
            }
            var code = 0
            if let response = response as? HTTPURLResponse {
                code = response.statusCode
            }
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let base64Str = json["content"] as? String {
                    let base64String = base64Str.replacingOccurrences(of: "\n", with: "")
                    if let da = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions.init(rawValue: 0)),
                       let dataString = String(data: da as Data, encoding: .utf8),
                       let jsonData = dataString.data(using: .utf8),
                       let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any] {
                        DispatchQueue.main.async {
                            callback(jsonObject, nil)
                        }
                    }else {
                        callback([], "data error code:\(code)")
                    }
                }else {
                    //获取不到数据，需要更新token
                    callback([], "data error code:\(code)")
                    
                }
            }
        }
        task.resume()
    }
    static func getToken(callback:@escaping (_ datas: [String: Any]?, _ err: String?) -> Void) {
        let url = URL(string: getTokenUrl)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                callback(nil, error.localizedDescription)
                return
            }
            var code = 0
            if let response = response as? HTTPURLResponse {
                code = response.statusCode
            }
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                callback(json, "data error code:\(code)")
            }
            else {
                callback(nil, "data error code:\(code)")
            }
        }
        task.resume()
    }
    
}

struct HTTPResponse1: Decodable {
    let json: HTTPResponse2
    
}

struct HTTPResponse2: Decodable {
    let sha: String
    
}
