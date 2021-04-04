//
//  GitGrassIndicator.swift
//  application main class
//
//  Created by EnchantCode on 2021/04/04.
//

import Swifter
import CoreImage
import Foundation

final class GitGrassIndicator{
    
    final func main(arguments: [String]) -> Int32 {
        // 実行引数をもとにSwifterのインスタンスを生成
        print("Prepare...")
        let apikey: APIKey
        if arguments.count == 5{
            apikey = APIKey(consumerKey: arguments[1], consumerSecret: arguments[2], oauthToken: arguments[3], oauthTokenSecret: arguments[4])
        }else{
            apikey = APIKey()
        }
        let swifter = Swifter(apikey: apikey)
        
        
        var iconImage: CIImage?
        var contributionLevel: UInt?
        
        // showUserを実行し待機
        print("Fetch userobject...")
        var response: JSON?
        let fetchUserSema = DispatchSemaphore(value: 0)
        swifter.showUser(.id("1243395100387897347"), includeEntities: true) { (json) in
            response = json
            fetchUserSema.signal()
        } failure: { (error) in
            print(error)
            fetchUserSema.signal()
        }
        fetchUserSema.wait()
        
        // アイコンURLを取得、CIImageに変換
        print("Generate CIImage...")
        guard let iconImageURLString = response?["profile_image_url_https"].string?.replacingOccurrences(of: "_normal", with: ""),
              let iconImageURL = URL(string: iconImageURLString),
              let iconImageData = try? Data(contentsOf: iconImageURL) else {
            return EXIT_FAILURE
        }
        iconImage = CIImage(data: iconImageData)
        
        // contributionを取得
        print("Fetch last contribution...")
        
        let fetchContributionSema = DispatchSemaphore(value: 0)
        let parser = ContributionXMLParser(userName: "Enchan1207")!
        try! parser.fetchContributions { (contributions) in
            contributionLevel = contributions.last?.level
            fetchContributionSema.signal()
        }
        fetchContributionSema.wait()
        
        guard iconImage != nil, contributionLevel != nil else {return EXIT_FAILURE}
        
        // アイコン画像にフィルタをかけて
        print("Image processing...")
        let lastContributionLevelColor = GrassColor(rawValue: Int(contributionLevel!))!
        let colors: [CGColor] = [
            lastContributionLevelColor.lightAppearanceColor!,
            lastContributionLevelColor.darkAppearanceColor!
        ]
        let filterSema = DispatchSemaphore(value: 0)
        var filteredImage: CGImage?
        ImageDrawer(ciImage: iconImage!)!.generateCenterCircleFilteredImage(colors: colors, radius: 195, thickness: 25, completion: { (image) in
            filteredImage = image
            filterSema.signal()
        })
        filterSema.wait()
        
        // Twitterに反映
        print("Icon update...")
        guard  #available(OSX 10.13, *) else {return EXIT_FAILURE}
        let iconUpdateSema = DispatchSemaphore(value: 0)
        var iconUpdateResult: Int32 = EXIT_SUCCESS
        let imageData = ImageFormatter().generatePNGImageData(image: CIImage(cgImage: filteredImage!))!
        swifter.updateProfileImage(using: imageData) { (json) in
            print("Success!")
            iconUpdateSema.signal()
            iconUpdateResult = EXIT_SUCCESS
        } failure: { (error) in
            print("Failed.")
            print(error)
            iconUpdateSema.signal()
            iconUpdateResult = EXIT_FAILURE
        }
        iconUpdateSema.wait()
        
        return iconUpdateResult
    }
}
