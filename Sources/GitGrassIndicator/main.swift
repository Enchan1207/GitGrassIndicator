//
//  main.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation
import CoreImage
import ArgumentParser
import Swifter

// 実行引数 GHActionsで実行する際に挿入できるように
struct GitGrassIndicatorOptions: ParsableArguments {
    @Argument() var consumerKey: String
    @Argument() var consumerSecret: String
    @Argument() var oauthToken: String
    @Argument() var oauthSecret: String
}

private func main(args: [String]){
    print("Process started.")
    
    // 実行引数をもとにSwifterのインスタンスを生成
    let options: GitGrassIndicatorOptions?
    do {
        options = try GitGrassIndicatorOptions.parse()
    } catch {
        print(GitGrassIndicatorOptions.helpMessage())
        options = nil
    }
    
    let apikey: APIKey
    if let options = options {
        apikey = APIKey(consumerKey: options.consumerKey, consumerSecret: options.consumerSecret, oauthToken: options.oauthToken, oauthTokenSecret: options.oauthSecret)
    }else{
        apikey = APIKey()
    }
    
    let swifter = Swifter(apikey: apikey)
    
    // ユーザオブジェクトを持ってきて
    print("Fetch user object...")
    swifter.showUser(.screenName("EnchanLab"), includeEntities: true) { (json) in
        // アイコン画像を取得し
        print("Get icon image...")
        guard
            let iconImageURLString = json["profile_image_url_https"].string?.replacingOccurrences(of: "_normal", with: ""),
            let iconImageURL = URL(string: iconImageURLString) else {return}
        
        guard let iconImageData = try? Data(contentsOf: iconImageURL),
              let iconImage = CIImage(data: iconImageData) else{return}
        
        // GitHub Contribution Graphから今日の草の色を取得して
        print("Fetch last contribution...")
        let parser = ContributionXMLParser(userName: "Enchan1207")
        try? parser?.fetchContributions(completion: { (contributions) in
            guard
                let lastContributionLevel = contributions.last?.level,
                let lastContributionLevelColor = GrassColor(rawValue: Int(lastContributionLevel)) else {return}
            
            // アイコン画像にフィルタをかけて
            print("Image filtering...")
            let colors: [CGColor] = [
                lastContributionLevelColor.lightAppearanceColor!,
                lastContributionLevelColor.darkAppearanceColor!
            ]
            ImageDrawer(ciImage: iconImage)?.generateCenterCircleFilteredImage(colors: colors, radius: 195, thickness: 25, completion: { (cgImage) in
                
                // Twitterに反映
                print("Icon update...")
                guard  #available(OSX 10.13, *) else{return}
                guard let imageData = ImageFormatter().generatePNGImageData(image: CIImage(cgImage: cgImage!)) else {return}
                
                // (ファイルに投げる場合はこう)
                //                try? imageData.write(to: URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop/ccc.png"))
                //                exit(EXIT_SUCCESS)
                
                swifter.updateProfileImage(using: imageData) { (json) in
                    print("Success!")
                    print(json)
                    exit(EXIT_SUCCESS)
                } failure: { (error) in
                    print("Failed.")
                    print(error.localizedDescription)
                    exit(EXIT_FAILURE)
                }
                
            })
        })
    } failure: { (error) in
        print("Failed.")
        print(error.localizedDescription)
        exit(EXIT_FAILURE)
    }
}

main(args: CommandLine.arguments)
RunLoop.main.run()
