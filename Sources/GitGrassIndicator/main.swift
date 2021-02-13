//
//  main.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation
import CoreImage

private func main(args: [String]){
    // 画像を持ってきて
    let ciContext = CIContext()
    print("call image from assets...")
        guard #available(OSX 10.12, *),
              let ciImage = CIImage(contentsOf: URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop/icon.jpg")),
              let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {return}
    
    // Drawerにつっこみ
    print("Drawing...")
    let drawer = ImageDrawer(cgImage: cgImage)
    drawer.apply { (context) in
        // 円を描く
        let imageRect = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
        context.draw(cgImage, in: imageRect)
        
        let diff: CGFloat = 10.0
        let clipPath = CGPath(ellipseIn: CGRect(x: diff, y: diff, width: imageRect.width - diff * 2, height: imageRect.height - diff * 2), transform: nil)
        context.saveGState()
        context.setLineWidth(20)
        context.addPath(clipPath)
        context.replacePathWithStrokedPath()
        context.clip()
        
        // グラデ
        let colors: [CGColor] = [
            .fromHexCode("#FF0000"),
            .fromHexCode("#00FF00"),
        ]
        let offsets = [ CGFloat(0.0), CGFloat(1.0) ]
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: offsets)
        let start = imageRect.origin
        let end = CGPoint(x: imageRect.maxX, y: imageRect.maxY)
        context.drawLinearGradient(grad!, start: start, end: end, options: [])

        context.restoreGState()
        
    } completion: { (image) in
        // 保存
        print("save...")
        guard #available(OSX 10.13, *) else{return}
        let filteredImageData = ImageFormatter().generatePNGImageData(image: CIImage(cgImage: image!))
        try? filteredImageData?.write(to: URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop/filtered.png"))
        exit(EXIT_SUCCESS)
    }
}

main(args: CommandLine.arguments)
RunLoop.main.run()
