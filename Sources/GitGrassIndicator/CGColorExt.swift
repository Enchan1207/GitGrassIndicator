//
//  CGColorExt.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/12.
//

import CoreGraphics

extension CGColor {
    /// カラーコード (#RRGGBB形式) からCGColor生成
    ///  - Parameters:
    ///     - code: 変換対象のカラーコード文字列
    ///  - Returns: カラーコードから生成したCGColor?
    public static func fromHexCode(_ code: String) -> CGColor{
        let code = code.replacingOccurrences(of: "#", with: "")
        guard code.count == 6 else {return .clear}
        
        // 各色成分に分割し、CGFloatに変換
        let splittedComponents =
            code // codeを
            .split(each: 2) // 2文字ずつ分割して
            .map({Double(Int($0, radix: 16) ?? 0)}) // 10進数に変換し
            .map({CGFloat($0 / 255.0)}) // 0.0~1.0に変換
        
        return CGColor(red: splittedComponents[0], green: splittedComponents[1], blue: splittedComponents[2], alpha: 1)
    }
}


extension String{
    // n文字ずつ分割
    func split(each: Int) -> [String]{
        var elements: [String] = []
        var presentIndex = self.startIndex
        
        while true {
            guard let currentIndex = self.index(presentIndex, offsetBy: each, limitedBy: self.endIndex) else {break}
            elements.append(String(self[presentIndex..<currentIndex]))
            presentIndex = currentIndex
        }
        return elements
    }
}
