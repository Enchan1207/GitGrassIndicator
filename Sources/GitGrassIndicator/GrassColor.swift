//
//  GrassColor.swift
//  GitGrassIndicator
//
//  Created by EnchantCode on 2021/02/12.
//

import Foundation
import CoreGraphics

enum GrassColor: Int {
    case Level0 = 0
    case Level1 = 1
    case Level2 = 2
    case Level3 = 3
    case Level4 = 4
    
    var color: CGColor? {
        switch self {
        case .Level0:
            return .fromHexCode("#161B22")
        case .Level1:
            return .fromHexCode("#003820")
        case .Level2:
            return .fromHexCode("#00602D")
        case .Level3:
            return .fromHexCode("#10983D")
        case .Level4:
            return .fromHexCode("#27D545")
        }
    }
}
