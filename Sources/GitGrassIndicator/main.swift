//
//  main.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation
import CoreImage

private func main(args: [String]){
    print("Process started.")
    let swifterClient = SwifterClient(credential: APIKey())
    
    // ユーザオブジェクトを持ってきて
    print("Fetch user object...")
    swifterClient.showUser(userTag: .screenName("EnchanLab")) { (json) in
        guard let json = json else {return}
        
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
                
                swifterClient.updateProfileImage(imageData: imageData) { (json) in
                    print("Success!")
                    print(json)
                    exit(EXIT_SUCCESS)
                }
            })
        })
    }
}

main(args: CommandLine.arguments)
RunLoop.main.run()
