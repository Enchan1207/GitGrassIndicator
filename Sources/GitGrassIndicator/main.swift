//
//  main.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation
import CoreImage

private func main(args: [String]){
    
    let semaphore = DispatchSemaphore(value: 0)
    
    // プロフィール情報取得
    print("Process started.")
    let swifterClient = SwifterClient(credential: APIKey())
    guard let userInfo = swifterClient.showUser(userTag: .screenName("EnchanLab")) else{
        semaphore.signal()
        return
    }
    
    // プロフ画像取得
    print("Get profile image...")
    guard let profileImageData = try? Data(contentsOf: URL(string: userInfo["profile_image_url_https"].string!.replacingOccurrences(of: "_normal", with: ""))!) else {
        semaphore.signal()
        return
    }

    // GitHubコントリビューション情報取得
    let contributionXMLParser = ContributionXMLParser(userName: "Enchan1207")
    do{
        try contributionXMLParser?.fetchContributions(completion: { (contributions) in
            // 生やす草の色を取得
            print("Get grass color...")
            guard let lastContribution = contributions.last else {
                semaphore.signal()
                return
            }
            let grassColor = GrassColor(rawValue: Int(lastContribution.level))
            
            // フィルタをかける
            print("Image processing...")
            guard let ciImage = CIImage(data: profileImageData) else {
                semaphore.signal()
                return
            }
            guard let filter = ImageDrawer(ciImage: ciImage) else {
                semaphore.signal()
                return
            }
            
            filter.generateCenterCircleFilteredImage(color: grassColor!.color!, radius: 190, thickness: 20) { (cgImage) in
                if #available(OSX 10.13, *) {
                    // PNGイメージ生成
                    print("Generate PNG image...")
                    guard let filteredImageData = ImageFormatter().generatePNGImageData(image: CIImage(cgImage: cgImage!)) else {
                        semaphore.signal()
                        return
                    }
                    
                    // アイコン更新
                    print("Update icon...")
                    guard let _ = swifterClient.updateProfileImage(imageData: filteredImageData) else {
                        semaphore.signal()
                        return
                    }
                    
                    print("All Process has been finished successfully!")
                    semaphore.signal()
                }
            }
        })
    }catch{
        fatalError(error.localizedDescription)
    }
    
    semaphore.wait()
}

main(args: CommandLine.arguments)
