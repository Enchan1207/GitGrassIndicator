//
//  main.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation
import CoreImage

private func main(args: [String]){
    let swifterClient = SwifterClient(credential: APIKey())
    
    // ユーザオブジェクトを持ってきて
    swifterClient.showUser(userTag: .screenName("EnchanLab")) { (json) in
        guard let json = json else {return}
        
        // アイコン画像を取得し
        guard
            let iconImageURLString = json["profile_image_url_https"].string?.replacingOccurrences(of: "_normal", with: ""),
            let iconImageURL = URL(string: iconImageURLString) else {return}
        
        guard let iconImageData = try? Data(contentsOf: iconImageURL),
              let iconImage = CIImage(data: iconImageData) else{return}
        
        // GitHub Contribution Graphから今日の草の色を取得して
        let parser = ContributionXMLParser(userName: "Enchan1207")
        try? parser?.fetchContributions(completion: { (contributions) in
            guard
                let lastContributionLevel = contributions.last?.level,
                let lastContributionLevelColor = GrassColor(rawValue: Int(lastContributionLevel))?.color else {return}
            
            // アイコン画像にフィルタをかけて
            ImageDrawer(ciImage: iconImage)?.generateCenterCircleFilteredImage(color: lastContributionLevelColor, radius: 195, thickness: 25, completion: { (cgImage) in
                
                // Twitterに反映
                if #available(OSX 10.13, *) {
                    guard let imageData = ImageFormatter().generatePNGImageData(image: CIImage(cgImage: cgImage!)) else {return}
                    
                    swifterClient.updateProfileImage(imageData: imageData) { (json) in
                        print(json)
                        exit(EXIT_SUCCESS)
                    }
                }
            })
        })
    }
}

main(args: CommandLine.arguments)
RunLoop.main.run()
