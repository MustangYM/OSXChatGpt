//
//  ServerManager.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/1.
//

import Foundation

let getTokenUrl = "https://raw.githubusercontent.com/CoderLineChan/data/main/data/token.json"
let githubUrl = "https://api.github.com/repos/CoderLineChan/OSXChatGptDataUpload/contents/data"
let githubGetUrl = "https://api.github.com/repos/CoderLineChan/OSXChatGptData/contents/data/data.json"

class ServerManager {
    static let shared = ServerManager()
    
    var getDataToken: String = ""
    var uploadDataToken: String = ""
    
    private var repetCount: Int = 0
    private var loading: Bool = false
    
    func checkToken() {
        if !getDataToken.isEmpty && !uploadDataToken.isEmpty {
            return
        }
        if loading {
            return
        }
        loading = true
        HTTPClient.getToken { [weak self] data, err in
            guard let self = self else { return }
            if let json = data {
                if let getDataBase64 = json["getData"] as? String,
                   let da = NSData(base64Encoded: getDataBase64, options: NSData.Base64DecodingOptions.init(rawValue: 0)),
                   let dataString = String(data: da as Data, encoding: .utf8) {
                    self.getDataToken = dataString
                    print("获取getDataToken成功")
                }else {
                    print("获取getDataToken失败")
                }
                if let uploadDataBase64 = json["uploadData"] as? String,
                   let da = NSData(base64Encoded: uploadDataBase64, options: NSData.Base64DecodingOptions.init(rawValue: 0)),
                   let dataString = String(data: da as Data, encoding: .utf8) {
                    self.uploadDataToken = dataString
                    print("获取uploadDataToken成功")
                }else {
                    print("获取uploadDataToken失败")
                }
                self.loading = false
                if self.uploadDataToken.isEmpty || self.getDataToken.isEmpty {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                        self.checkToken()
                    }
                }
            }else {
                print("获取Token失败")
                self.loading = false
                DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                    self.checkToken()
                }
            }
        }
        
    }
    
}
