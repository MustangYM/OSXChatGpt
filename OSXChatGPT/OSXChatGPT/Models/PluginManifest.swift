//
//  PluginManifest.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/6/15.
//

import Foundation


struct PluginManifest {
    var schema_version: String = ""
    var name_for_human: String = ""
    var name_for_model: String = ""
    var description_for_human: String = ""
    var description_for_model: String = ""
    var auth: PluginManifestAuth = PluginManifestAuth()
    var api: PluginManifestAPI = PluginManifestAPI()
    var logo_url: String = ""
    var contact_email: String = ""
    var legal_info_url: String = ""
}


struct PluginManifestAuth {
    var type: String = ""
}

struct PluginManifestAPI {
    var type: String = ""
    var url: String = ""
    var has_user_authentication: Bool = false
}

//  "auth": {
//    "type": "oauth",
//    "authorization_content_type": "application/x-www-form-urlencoded",
//    "client_url": "https://auth.buildbetter.app/realms/buildbetter/protocol/openid-connect/auth",
//    "authorization_url": "https://auth.buildbetter.app/realms/buildbetter/protocol/openid-connect/token",
//    "scope": "email profile",
//    "verification_tokens": {
//      "openai": "28e7c6a759b94f4cac07cd4693433997"
//    }
//  },
