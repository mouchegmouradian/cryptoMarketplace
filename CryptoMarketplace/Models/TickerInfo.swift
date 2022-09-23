//
//  TickerInfo.swift
//  CryptoMarketplace
//

import Foundation

struct TickerInfo: Equatable {
    let ticker: String
    let first: SymbolInfo
    let second: SymbolInfo

    init(ticker: String, first: SymbolInfo, second: SymbolInfo) {
        self.ticker = ticker.uppercased()
        self.first = first
        self.second = second
    }
}
