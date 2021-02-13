//
//  SwifterExt.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/13.
//

import Foundation
import Swifter

extension Swifter{
    convenience init(apikey: APIKey){
        self.init(consumerKey: apikey.CONSUMER_KEY, consumerSecret: apikey.CONSUMER_SECRET, oauthToken: apikey.OAUTH_TOKEN, oauthTokenSecret: apikey.OAUTH_SECRET)
    }
}
