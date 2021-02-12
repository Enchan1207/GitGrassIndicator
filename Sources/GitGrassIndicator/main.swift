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
    swifterClient.showUser(userTag: .screenName("EnchanLab")) { (json) in
        guard let json = json else {return}
        
        // プロフ画像取得
        guard let profileImageData = try? Data(contentsOf: URL(string: json["profile_image_url_https"].string!.replacingOccurrences(of: "_normal", with: ""))!) else{return}
        
        // GitHubコントリビューション情報取得
        let contributionXMLParser = ContributionXMLParser(userName: "Enchan1207")
        do{
            try contributionXMLParser?.fetchContributions(completion: { (contributions) in
                // 生やす草の色を取得
                guard let lastContribution = contributions.last else{return}
                let grassColor = GrassColor(rawValue: Int(lastContribution.level))
                
                // フィルタをかける
                guard let ciImage = CIImage(data: profileImageData) else {return}
                guard let filter = ImageDrawer(ciImage: ciImage) else {return}
                
                filter.generateCenterCircleFilteredImage(color: GrassColor.Level3.color!, radius: 200, thickness: 15) { (cgImage) in
                    if #available(OSX 10.13, *) {
                        // PNGイメージ生成
                        guard let filteredImageData = ImageFormatter().generatePNGImageData(image: CIImage(cgImage: cgImage!)) else {return}
                        
                        // アイコン更新
//                        swifterClient.updateProfileImage(imageData: filteredImageData) { (json) in
//                            print(json)
//                        }
                    }
                }
            })
        }catch{
            fatalError(error.localizedDescription)
        }
    }
}

main(args: CommandLine.arguments)
