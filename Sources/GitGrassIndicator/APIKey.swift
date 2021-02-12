//
//  APIKey.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation

struct APIKey {
    let CONSUMER_KEY: String
    let CONSUMER_SECRET: String
    let OAUTH_TOKEN: String
    let OAUTH_SECRET: String
    
    init(consumerKey: String?=nil, consumerSecret: String?=nil, oauthToken: String?=nil, oauthTokenSecret: String?=nil){
        CONSUMER_KEY = consumerKey ?? "XXXXXX"
        CONSUMER_SECRET = consumerSecret ?? "XXXXXX"
        OAUTH_TOKEN = oauthToken ?? "XXXXXX"
        OAUTH_SECRET = oauthTokenSecret ?? "XXXXXX"
    }
}
