//
//  CircleFilter.swift - 画像に色々描画
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/11.
//

import Foundation
import CoreImage
import CoreGraphics

class ImageDrawer {
    
    private static let ciContext = CIContext()
    private let cgContext: CGContext?
    private let cgImage: CGImage
    
    init(cgImage: CGImage){
        self.cgImage = cgImage
        self.cgContext = Self.generateCGContext(cgImage: cgImage)
    }
    
    convenience init?(ciImage: CIImage) {
        guard let cgImage = Self.ciContext.createCGImage(ciImage, from: ciImage.extent) else{return nil}
        self.init(cgImage: cgImage)
    }
    
    // CGContext生成
    internal static func generateCGContext(cgImage: CGImage) -> CGContext?{
        guard let cgContext = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: cgImage.bytesPerRow,
            space: cgImage.colorSpace!,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        )else{return nil}
        
        return cgContext
    }
    
    // contextに任意の処理を加える
    func apply(process: (_ context:CGContext) -> Void){
        if let cgContext = self.cgContext{
            process(cgContext)
        }
    }
    
    // 現在のContextからCGImageを生成
    func generateImageFromContext() -> CGImage?{
        return self.cgContext?.makeImage()
    }
    
}

extension ImageDrawer{
    // contributionリングの描画
    func generateCenterCircleFilteredImage(colors: [CGColor], radius: CGFloat, thickness: CGFloat, completion: (_ image: CGImage?) -> Void){
        
        self.apply { (context) in
            // CGImageを描いて
            let imageRect = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
            context.draw(cgImage, in: imageRect)
                
            // 円を描く
            let origin = CGPoint(x: cgImage.width / 2, y: cgImage.height / 2)
            let ellipseRect = CGRect(x: origin.x - radius, y: origin.y - radius, width: radius * 2, height: radius * 2)
            let clipPath = CGPath(ellipseIn: ellipseRect, transform: nil)
            context.saveGState()
            context.setLineWidth(thickness)
            context.addPath(clipPath)
            context.replacePathWithStrokedPath()
            context.clip()
            
            // グラデ
            let offsets = [ CGFloat(0.0), CGFloat(1.0) ]
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: offsets)
            
            let start = CGPoint(x: imageRect.minX, y: imageRect.minY)
            let end = CGPoint(x: imageRect.maxX, y: imageRect.maxY)
            
            context.drawLinearGradient(grad!, start: start, end: end, options: [])
            
            context.restoreGState()
            
            completion(self.generateImageFromContext())
        }
    }
}
