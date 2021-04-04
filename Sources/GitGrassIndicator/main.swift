//
//  main.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation
import CoreImage
import Swifter

// 実行引数をもとにSwifterのインスタンスを生成
let apikey: APIKey
let arguments = CommandLine.arguments
if arguments.count == 5{
    apikey = APIKey(consumerKey: arguments[1], consumerSecret: arguments[2], oauthToken: arguments[3], oauthTokenSecret: arguments[4])
}else{
    apikey = APIKey()
}
let swifter = Swifter(apikey: apikey)

// セマンティウス2世
let sema = DispatchSemaphore(value: 0)

DispatchQueue.main.async {
    print("ここは動かねえだろ!")
}

DispatchQueue.global(qos: .utility).async {
    print("Waiting...")
    sema.wait()
    sema.wait()
    sema.wait()
    sema.wait()
    exit(EXIT_SUCCESS)
}

DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
    print("Signal 1!")
    sema.signal()
}

DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 4) {
    print("Signal 2!")
    sema.signal()
}

DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 6) {
    let urlSessionSema = DispatchSemaphore(value: 0)
    URLSession.shared.dataTask(with: URL(string: "https://example.com")!) { (data, response, error) in
        guard let data = data else {
            urlSessionSema.signal()
            return
        }
        print(String(data: data, encoding: .utf8)!)
        urlSessionSema.signal()
    }.resume()
    urlSessionSema.wait()
    
    print("Signal 3!")
    sema.signal()
}

DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 8) {
    let swifterSema = DispatchSemaphore(value: 0)
    swifter.showUser(.screenName("EnchanLab"), includeEntities: true) { (json) in
        print(json)
        swifterSema.signal()
    } failure: { (error) in
        print(error)
        swifterSema.signal()
    }
    RunLoop.current.run()
    swifterSema.wait()
    sema.signal()
}

dispatchMain()
