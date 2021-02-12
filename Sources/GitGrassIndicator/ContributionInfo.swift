//
//  ContributionInfo.swift
//  GrassGraphViewer
//
//  Created by EnchantCode on 2021/02/04.
//
import Foundation

struct ContributionInfo: Comparable, Codable {
    static func < (lhs: ContributionInfo, rhs: ContributionInfo) -> Bool {
        return lhs.date < rhs.date
    }
    
    let date: Date
    let contributionCount: UInt
    let level: UInt
}
