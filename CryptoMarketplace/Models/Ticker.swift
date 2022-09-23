//
//  Ticker.swift
//  CryptoMarketplace
//

import Foundation

// See response details section on the following page for more details: https://docs.bitfinex.com/reference/rest-public-tickers

struct Ticker: Equatable {
    // if symbol starts with an 'f' then it's a funding ticker, if it starts with a 't' then it's not
    let isFundingTicker: Bool

    let symbol: String
    // average of all fixed rate funding over the last hour (funding tickers only)
    let flashReturnRate: Double?
    // Price of last highest bid
    let bidPrice: Double
    // Bid period covered in days (funding tickers only)
    let bidPeriod: Int?
    // Sum of the 25 highest bid sizes
    let bidSize: Double
    // Price of last lowest ask
    let askPrice: Double
    // Ask period covered in days (funding tickers only)
    let askPeriod: Int?
    // Sum of the 25 lowest ask sizes
    let askSize: Double
    // Amount that the last price has changed since yesterday
    let dailyChange: Double
    // Relative price change since yesterday (*100 for percentage change)
    let dailyChangeRelative: Double
    // Price of the last trade
    let lastPrice: Double
    // Daily volume
    let volume: Double
    // Daily high
    let high: Double
    // Daily low
    let low: Double
    // The amount of funding that is available at the Flash Return Rate (funding tickers only)
    let frrAmount: Double?

    init(isFundingTicker: Bool, symbol: String, flashReturnRate: Double?, bidPrice: Double, bidPeriod: Int?, bidSize: Double, askPrice: Double, askPeriod: Int?, askSize: Double, dailyChange: Double, dailyChangeRelative: Double, lastPrice: Double, volume: Double, high: Double, low: Double, frrAmount: Double?) {
        self.isFundingTicker = isFundingTicker
        self.symbol = symbol.uppercased()
        self.flashReturnRate = flashReturnRate
        self.bidPrice = bidPrice
        self.bidPeriod = bidPeriod
        self.bidSize = bidSize
        self.askPrice = askPrice
        self.askPeriod = askPeriod
        self.askSize = askSize
        self.dailyChange = dailyChange
        self.dailyChangeRelative = dailyChangeRelative
        self.lastPrice = lastPrice
        self.volume = volume
        self.high = high
        self.low = low
        self.frrAmount = frrAmount
    }
}

// MARK: - Codable

extension Ticker: Codable {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        symbol = try container.decode(String.self)

        isFundingTicker = symbol.first == "F"

        if isFundingTicker {
            flashReturnRate = try? container.decode(Double.self)
        } else {
            flashReturnRate = nil
        }

        bidPrice = try container.decode(Double.self)

        if isFundingTicker {
            bidPeriod = try? container.decode(Int.self)
        } else {
            bidPeriod = nil
        }


        bidSize = try container.decode(Double.self)
        askPrice = try container.decode(Double.self)

        if isFundingTicker {
            askPeriod = try? container.decode(Int.self)
        } else {
            askPeriod = nil
        }

        askSize = try container.decode(Double.self)
        dailyChange = try container.decode(Double.self)
        dailyChangeRelative = try container.decode(Double.self)
        lastPrice = try container.decode(Double.self)
        volume = try container.decode(Double.self)
        high = try container.decode(Double.self)
        low = try container.decode(Double.self)

        if isFundingTicker {
            frrAmount = try? container.decode(Double.self)
        } else {
            frrAmount = nil
        }
    }
}
