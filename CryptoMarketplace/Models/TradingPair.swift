//
//  TradingPair.swift
//  CryptoMarketplace
//

import Foundation

// MARK: - TradingPairWrapper

struct TradingPairWrapper {
    let pairs: [TradingPair]
}

// MARK: Codable

extension TradingPairWrapper: Codable {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var data: [TradingPair] = []

        while !container.isAtEnd {
            if let ticker = try? container.decode(String.self) {
                data.append(TradingPair(ticker: ticker))
            }
        }

        pairs = data
    }
}


// MARK: - TradingPair

struct TradingPair {
    let ticker: String

    init(ticker: String) {
        self.ticker = ticker.uppercased()
    }

    var first: String {
        if ticker.contains(":") {
            return ticker.components(separatedBy: ":")[0]
        } else if 3 <= ticker.count {
            let midIndex = ticker.index(ticker.startIndex, offsetBy: 3)

            return String(ticker[ticker.startIndex..<midIndex])
        }

        return ""
    }

    var second: String {
        if ticker.contains(":") {
            return ticker.components(separatedBy: ":")[1]
        } else if 3 <= ticker.count {
            let midIndex = ticker.index(ticker.startIndex, offsetBy: 3)

            return String(ticker[midIndex..<ticker.endIndex])
        }

        return ""
    }
}

// MARK: Codable

extension TradingPair: Codable {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        ticker = try container.decode(String.self)
    }
}
