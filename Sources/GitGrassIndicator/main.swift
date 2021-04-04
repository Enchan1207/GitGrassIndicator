//
//  main.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation
import CoreImage
import Swifter


func main(arguments: [String]) -> Int32 {
    // 実行引数をもとにSwifterのインスタンスを生成
    let apikey: APIKey
    
    if arguments.count == 5{
        apikey = APIKey(consumerKey: arguments[1], consumerSecret: arguments[2], oauthToken: arguments[3], oauthTokenSecret: arguments[4])
    }else{
        apikey = APIKey()
    }
    let swifter = Swifter(apikey: apikey)
    
    // セマンティウス2世
    let sema = DispatchSemaphore(value: 0)
    
    var username: String?
    swifter.showUser(.screenName("EnchanLab"), includeEntities: true) { (json) in
        username = "\(json["name"].string ?? "User") (@\(json["screen_name"].string ?? "User"))"
        sema.signal()
    } failure: { (error) in
        print(error)
        sema.signal()
    }
    sema.wait()
    
    guard username != nil else {return EXIT_FAILURE}
    
    print(username!)
    
    return EXIT_SUCCESS
}

let arguments = CommandLine.arguments
DispatchQueue.global(qos: .userInteractive).async {
    let result = main(arguments: arguments)
    exit(result)
}

dispatchMain()
