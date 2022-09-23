//
//  MarketService.swift
//  CryptoMarketplace
//

import RxSwift
import Moya

class MarketService: MarketServiceProtocol {

    private lazy var bitfinexProvider: MoyaProvider<BitfinexAPI> = MoyaProvider<BitfinexAPI>()

    func getTradingPairs() -> Single<[TradingPair]> {
        return bitfinexProvider.rx
            .request(.getPairs)
            .filterSuccessfulStatusAndRedirectCodes()
            .map([TradingPairWrapper].self)
            .map { $0[0].pairs }
            .catchAndReturn([])
    }

    func getSymbols() -> Single<[SymbolName]> {
        return bitfinexProvider.rx
            .request(.getSymbols)
            .filterSuccessfulStatusAndRedirectCodes()
            .map([SymbolNameWrapper].self)
            .map { $0[0].symbols }
            .catchAndReturn([])
    }

    func getLabels() -> Single<[SymbolName]> {
        return bitfinexProvider.rx
            .request(.getLabels)
            .filterSuccessfulStatusAndRedirectCodes()
            .map([SymbolNameWrapper].self)
            .map { $0[0].symbols }
            .catchAndReturn([])
    }

    func getTickers(symbols: [String]) -> Single<[Ticker]> {
        return bitfinexProvider.rx
            .request(.getTickers(symbols: symbols))
            .filterSuccessfulStatusAndRedirectCodes()
            .map([Ticker].self)
            .catchAndReturn([])
    }
}
