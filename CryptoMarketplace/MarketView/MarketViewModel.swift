//
//  MarketViewModel.swift
//  CryptoMarketplace
//

import Foundation
import RxSwift

class MarketViewModel {
    private let marketService: MarketServiceProtocol

    private lazy var _pairs = BehaviorSubject<[TickerInfo]>(value: [])
    private lazy var _tickers = BehaviorSubject<[Ticker]>(value: [])
    private lazy var _items = BehaviorSubject<[MarketTicker]>(value: [])

    private (set) lazy var items = self._items.asObservable()
    private (set) lazy var query = BehaviorSubject<String>(value: "")

    private let disposeBag = DisposeBag()

    private var dataStatus = DataStatus.none
    private var timer: Timer?

    init(service: MarketServiceProtocol) {
        marketService = service
    }

    func viewDidLoad() {
        getStartingInfo()

        _pairs.subscribe { [weak self] event in
            guard let tradingPairs = event.element else { return }
            guard !tradingPairs.isEmpty else { return }

            if self?.timer == nil {
                self?.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { [weak self] _ in
                    self?.updateTickers()
                })
            }

            self?.timer?.fire()
        }
        .disposed(by: disposeBag)

        _tickers.subscribe { [weak self] event in
            guard let tickers = event.element else { return }
            guard !tickers.isEmpty else { return }

            self?.createItems(tickers: tickers)
        }
        .disposed(by: disposeBag)

        query.subscribe { [weak self] event in
            guard let query = event.element else { return }

            self?.createItems(query: query)
        }
        .disposed(by: disposeBag)
    }
}

// MARK: - Private

private extension MarketViewModel {
    func createItems() {
        createItems(tickers: (try? _tickers.value()) ?? [],
                    query: (try? query.value()) ?? "")
    }

    func createItems(tickers: [Ticker]) {
        createItems(tickers: tickers, query: (try? query.value()) ?? "")
    }
    
    func createItems(query: String) {
        createItems(tickers: (try? _tickers.value()) ?? [], query: query)
    }

    func createItems(tickers: [Ticker], query: String) {
        guard let pairs = try? _pairs.value() else { return }
        let queryString = query.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        let marketTickers: [MarketTicker] = tickers.compactMap { ticker in
            // we are droping the first character from the ticker as it is the 't' or 'f'
            guard let pair = pairs.first(where: { $0.ticker == String(ticker.symbol.dropFirst(1)) }) else { return nil }
            guard queryString.isEmpty
                    || pair.first.realSymbol.contains(queryString)
                    || pair.first.name.contains(queryString)
                    || pair.second.realSymbol.contains(queryString)
                    || pair.second.name.contains(queryString)
                    || pair.ticker.contains(queryString)
            else { return nil }

            return MarketTicker(ticker: ticker, info: pair, status: dataStatus)
        }

        _items.onNext(marketTickers)
    }

    func getStartingInfo() {
        let sequence = Single.zip(
            marketService.getTradingPairs(),
            marketService.getSymbols(),
            marketService.getLabels()) { pairs, symbols, labels in

                let result: [TickerInfo] = pairs
                    .filter { $0.second == "USD" }
                    .compactMap { pair in
                        guard let fSymbol = symbols.first(where: { $0.symbol == pair.first  || $0.name == pair.first}) else { return nil }
                        guard let fLabel = labels.first(where: { $0.symbol == pair.first }) else { return nil }

                        // We could here get the symbol & label for pair.second if we wanted all pairs and not only USD pairs
                        let sSymbol = SymbolName(symbol: "USD", name: "USD")
                        let sLabel = SymbolName(symbol: "USD", name: "US Dollar")

                        let first = SymbolInfo(apiSymbol: fSymbol.symbol, realSymbol: fSymbol.name, name: fLabel.name)
                        let second = SymbolInfo(apiSymbol: sSymbol.symbol, realSymbol: sSymbol.name, name: sLabel.name)

                        return TickerInfo(ticker: pair.ticker, first: first, second: second)
                    }

                return result
            }

        sequence.subscribe { [weak self] (data: [TickerInfo]) in
            self?._pairs.onNext(data)
        } onFailure: { [weak self] (error: Error) in
            self?.dataStatus = .outdated
            self?.createItems()
        }
        .disposed(by: disposeBag)
    }

    func updateTickers() {
        let tradingPairs = (try? _pairs.value()) ?? []
        let symbols = tradingPairs.map { "t\($0.ticker)" }

        marketService.getTickers(symbols: symbols).subscribe { [weak self] (data: [Ticker]) in
            self?.dataStatus = .upToDate
            self?._tickers.onNext(data)
        } onFailure: { [weak self] (error: Error) in
            self?.dataStatus = .outdated
            self?.createItems()
        }
        .disposed(by: disposeBag)
    }
}
