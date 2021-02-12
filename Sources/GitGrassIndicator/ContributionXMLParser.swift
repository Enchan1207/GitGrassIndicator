//
//  ContributionXMLParser.swift
//  GrassGraphViewer
//
//  Created by EnchantCode on 2021/02/02.
//
import Foundation

class ContributionXMLParser: NSObject, XMLParserDelegate {
    
    private let dateFormatter = DateFormatter()
    private var completion: (([ContributionInfo]) -> ())?
    private var parser: XMLParser = XMLParser()
    private let contributionURL: URL!
    private var contributions: [ContributionInfo] = []
    
    // 草を見たいユーザのIDを渡す
    init?(userName: String) {
        // 草情報を提供するURLを生成
        guard let contributionURL = URL(string: "https://github.com/users/\(userName)/contributions") else{return nil}
        self.contributionURL = contributionURL
        
        self.completion = nil
        
        super.init()
        
        // DateFormatter初期化
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyy-M-d"
        
    }
    
    // フェッチして適当に整形してパース
    internal func fetchContributions(completion: (([ContributionInfo]) -> ())?) throws {
        
        // フェッチ
        guard let contributionData = try? Data(contentsOf: contributionURL) else {
            throw ContributionXMLParserError.fetchFailed
        }
        guard let contributionString = String(data: contributionData, encoding: .utf8) else{return}
        
        // XMLパーサにそのままかけると途中で止まる(XMLのルールに反する記述があるため)ので、
        // <svg>~</svg>を切り出す ここクソ実装
        guard let regex = try? NSRegularExpression(pattern: "<svg .+? class=\"js-calendar-graph-svg\">.+?</svg>", options: [.dotMatchesLineSeparators]) else {
            fatalError("Compile failed!")
        }
        guard let matchedResult = regex.firstMatch(in: contributionString, options: [], range: NSRange(0..<contributionString.count)) else {
            throw ContributionXMLParserError.svgSliceFailed
        }
        
        let start = contributionString.index(contributionString.startIndex, offsetBy: matchedResult.range.location)
        let end = contributionString.index(start, offsetBy: matchedResult.range.length)
        let SVGDataString = String(contributionString[start..<end])
        
        // パース開始
        parse(svgString: SVGDataString, completion: completion)
    }
    
    // SVGを直接突っ込んでパース開始 終わったら戻ってくる
    func parse(svgString: String, completion: (([ContributionInfo]) -> ())?){
        self.completion = completion
        self.parser = XMLParser(data: svgString.data(using: .utf8)!)
        self.parser.delegate = self
        self.parser.parse()
    }
    
    // 一応こういうのあったほうがいいんですかね?
    func getContributions() -> [ContributionInfo]{
        return self.contributions
    }
    
    // start to parse
    internal func parserDidStartDocument(_ parser: XMLParser) {
        self.contributions = []
    }
    
    // detect start of element
    internal func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        // contributionの情報が格納されていれば
        if
            let dataCount = attributeDict["data-count"],
            let dataDate = self.dateFormatter.date(from: attributeDict["data-date"] ?? ""),
            let dataLevel = attributeDict["data-level"]
        {
            
            // contributionsに追加
            self.contributions.append(ContributionInfo(date: dataDate, contributionCount: UInt(dataCount) ?? 0, level: UInt(dataLevel) ?? 0))
        }
    }
    
    // detect end of element
    internal func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    }
    
    // detect characters
    internal func parser(_ parser: XMLParser, foundCharacters string: String) {
    }
    
    internal func parserDidEndDocument(_ parser: XMLParser) {
        self.completion?(self.contributions)
    }
    
    internal func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        fatalError("ParseError: \(parseError)")
    }
}

enum ContributionXMLParserError: Error {
    case fetchFailed
    case svgSliceFailed
}
