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
    func apply(
        process: (_ context:CGContext)->Void,
        completion: ((_ image:CGImage?)->Void)? = nil){
        if let cgContext = self.cgContext{
            process(cgContext)
            completion?(generateImageFromContext())
        }
    }
    
    // 現在のContextからCGImageを生成
    func generateImageFromContext() -> CGImage?{
        return self.cgContext?.makeImage()
    }
    
    // 画像生成
    func generateCenterCircleFilteredImage(color: CGColor, radius: CGFloat, thickness: CGFloat, completion: (_ image: CGImage?) -> Void){
        
        self.apply { (context) in
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
            
            context.setLineWidth(thickness)
            context.setStrokeColor(color)
            
            let origin = CGPoint(x: cgImage.width / 2, y: cgImage.height / 2)
            let ellipseRect = CGRect(x: origin.x - radius, y: origin.y - radius, width: radius * 2, height: radius * 2)
            context.strokeEllipse(in: ellipseRect)
            
            completion(self.generateImageFromContext())
        }
    }
}
