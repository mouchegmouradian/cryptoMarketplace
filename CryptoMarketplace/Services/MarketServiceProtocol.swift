//
//  MarketServiceProtocol.swift
//  CryptoMarketplace
//

import RxSwift

protocol MarketServiceProtocol {
    func getSymbols() -> Single<[SymbolName]>
    func getLabels() -> Single<[SymbolName]>
    func getTradingPairs() -> Single<[TradingPair]>
    func getTickers(symbols: [String]) -> Single<[Ticker]>
}
