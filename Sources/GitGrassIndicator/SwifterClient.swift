//
//  SwifterClient.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation
import Swifter

class SwifterClient {
    private let swifter: Swifter
    
    init(credential: APIKey){
        swifter = Swifter(consumerKey: credential.CONSUMER_KEY, consumerSecret: credential.CONSUMER_SECRET, oauthToken: credential.OAUTH_TOKEN, oauthTokenSecret: credential.OAUTH_SECRET)
    }
    
    // ユーザオブジェクト取得
    func showUser(userTag: UserTag, completion: @escaping (_ json: JSON?) -> Void){
        swifter.showUser(userTag, includeEntities: true) { (json) in
            completion(json)
        } failure: { (error) in
            completion(nil)
        }
    }
    
    // ユーザアイコン更新
    func updateProfileImage(imageData: Data, completion: @escaping (_ json: JSON?) -> Void){
        swifter.updateProfileImage(using: imageData, includeEntities: true, skipStatus: false) { (json) in
            completion(json)
        } failure: { (error) in
            completion(nil)
        }
    }
}
