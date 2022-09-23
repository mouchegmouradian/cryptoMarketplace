//
//  MarketTicker.swift
//  CryptoMarketplace
//

import Foundation

enum DataStatus {
    case none
    case upToDate
    case outdated
}

struct MarketTicker: Equatable {
    let ticker: Ticker
    let info: TickerInfo
    let status: DataStatus
}
