//
//  SwifterExt.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/13.
//

import Foundation
import Swifter

extension Swifter{
    convenience init(credential: APIKey){
        self.init(consumerKey: credential.CONSUMER_KEY, consumerSecret: credential.CONSUMER_SECRET, oauthToken: credential.OAUTH_TOKEN, oauthTokenSecret: credential.OAUTH_SECRET)
    }
}
