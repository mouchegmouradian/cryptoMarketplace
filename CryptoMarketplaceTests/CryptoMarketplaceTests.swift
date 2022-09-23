//
//  CryptoMarketplaceTests.swift
//  CryptoMarketplaceTests
//

import XCTest
import RxSwift
@testable import CryptoMarketplace

enum AppError {
    case network(type: Enums.NetworkError)
    case custom(errorDescription: String?)

    class Enums { }
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .network(let type): return type.localizedDescription
            case .custom(let errorDescription): return errorDescription
        }
    }
}

// MARK: - Network Errors

extension AppError.Enums {
    enum NetworkError {
        case parsing
        case notFound
        case custom(errorCode: Int?, errorDescription: String?)
    }
}

extension AppError.Enums.NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .parsing: return "Parsing error"
            case .notFound: return "URL Not Found"
            case .custom(_, let errorDescription): return errorDescription
        }
    }

    var errorCode: Int? {
        switch self {
            case .parsing: return nil
            case .notFound: return 404
            case .custom(let errorCode, _): return errorCode
        }
    }
}

class MockService: MarketServiceProtocol {
    var symbols: [SymbolName] = []
    var labels: [SymbolName] = []
    var pairs: [TradingPair] = []
    var tickers: [Ticker] = []

    func getSymbols() -> Single<[SymbolName]> {
        return Single.just(symbols)
    }

    func getLabels() -> Single<[SymbolName]> {
        return Single.just(labels)
    }

    func getTradingPairs() -> Single<[TradingPair]> {
        return Single.just(pairs)
    }

    func getTickers(symbols: [String]) -> Single<[Ticker]> {
        return Single.just(tickers)
    }
}

private class ItemSpy {
    private (set) var items = [MarketTicker]()
    private var disposeBag = DisposeBag()

    init(_ observable: Observable<[MarketTicker]>) {
        observable.subscribe(onNext: { [weak self] items in
            self?.items = items
         })
        .disposed(by: disposeBag)
    }
}

class CryptoMarketplaceTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var mockService: MockService!
    private var sut: MarketViewModel!
    private var spy: ItemSpy!
    private var ticker1: Ticker!
    private var ticker2: Ticker!
    private var ticker3: Ticker!

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        mockService = MockService()
        sut = MarketViewModel(service: mockService)
        spy = ItemSpy(sut.items)

        ticker1 = Ticker(isFundingTicker: false, symbol: "tBtcUsD", flashReturnRate: nil, bidPrice: 1, bidPeriod: nil, bidSize: 2, askPrice: 2, askPeriod: nil, askSize: 2, dailyChange: 1, dailyChangeRelative: 0.5, lastPrice: 1.1, volume: 1, high: 2, low: 0, frrAmount: nil)
        ticker2 = Ticker(isFundingTicker: false, symbol: "tetHuSD", flashReturnRate: nil, bidPrice: 1, bidPeriod: nil, bidSize: 2, askPrice: 2, askPeriod: nil, askSize: 2, dailyChange: 1, dailyChangeRelative: 0.5, lastPrice: 1.1, volume: 1, high: 2, low: 0, frrAmount: nil)
        ticker3 = Ticker(isFundingTicker: false, symbol: "tlTcUSd", flashReturnRate: nil, bidPrice: 1, bidPeriod: nil, bidSize: 2, askPrice: 2, askPeriod: nil, askSize: 2, dailyChange: 1, dailyChangeRelative: 0.5, lastPrice: 1.1, volume: 1, high: 2, low: 0, frrAmount: nil)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        mockService = nil
        sut = nil
        ticker1 = nil
        ticker2 = nil
        ticker3 = nil
    }

    // MARK: Data test

    func testInitialState() throws {
        XCTAssertTrue(spy.items.isEmpty)
    }

    func testItemsWithNoData() throws {
        sut.viewDidLoad()
        XCTAssertTrue(spy.items.isEmpty)
    }

    func testItemsSuccess() throws {
        let tickerInfo = TickerInfo(ticker: "BtCuSD",
                                    first: SymbolInfo(apiSymbol: "BTc", realSymbol: "btc", name: "BItcoIN"),
                                    second: SymbolInfo(apiSymbol: "Usd", realSymbol: "usD", name: "us Dollar"))
        let expected = MarketTicker(ticker: ticker1, info: tickerInfo, status: .upToDate)

        mockService.symbols = [SymbolName(symbol: "bTC", name: "BTC")]
        mockService.labels = [SymbolName(symbol: "BtC", name: "BiTcoin")]
        mockService.pairs = [TradingPair(ticker: "BtcuSd")]
        mockService.tickers = [ticker1]

        sut.viewDidLoad()
        XCTAssertEqual(spy.items.count, 1)
        XCTAssertEqual(spy.items[0], expected)
    }

    func testItemsNoTicker() throws {
        mockService.symbols = [SymbolName(symbol: "bTC", name: "BTC")]
        mockService.labels = [SymbolName(symbol: "BtC", name: "BiTcoin")]
        mockService.pairs = [TradingPair(ticker: "BtcuSd")]

        sut.viewDidLoad()
        XCTAssertTrue(spy.items.isEmpty)
    }

    func testItemsNoSymbols() throws {
        mockService.labels = [SymbolName(symbol: "BtC", name: "BiTcoin")]
        mockService.pairs = [TradingPair(ticker: "BtcuSd")]
        mockService.tickers = [ticker1]

        sut.viewDidLoad()
        XCTAssertTrue(spy.items.isEmpty)
    }

    func testItemsWrongSymbols() throws {
        mockService.symbols = [SymbolName(symbol: "eTH", name: "ETH")]
        mockService.labels = [SymbolName(symbol: "BtC", name: "BiTcoin")]
        mockService.pairs = [TradingPair(ticker: "BtcuSd")]
        mockService.tickers = [ticker1]

        sut.viewDidLoad()
        XCTAssertTrue(spy.items.isEmpty)
    }

    func testItemsNoLabels() throws {
        mockService.symbols = [SymbolName(symbol: "bTC", name: "BTC")]
        mockService.pairs = [TradingPair(ticker: "BtcuSd")]
        mockService.tickers = [ticker1]

        sut.viewDidLoad()
        XCTAssertTrue(spy.items.isEmpty)
    }

    func testItemsWrongLabels() throws {
        mockService.symbols = [SymbolName(symbol: "BtC", name: "BiTcoin")]
        mockService.labels = [SymbolName(symbol: "eTH", name: "ETH")]
        mockService.pairs = [TradingPair(ticker: "BtcuSd")]
        mockService.tickers = [ticker1]

        sut.viewDidLoad()
        XCTAssertTrue(spy.items.isEmpty)
    }

    // MARK: Query testing

    func testEmptyQuery() throws {
        setupMockServiceForQueryTest()
        sut.viewDidLoad()

        sut.viewDidLoad()
        XCTAssertEqual(spy.items.count, 3)
        sut.query.onNext("")
        XCTAssertEqual(spy.items.count, 3)
    }

    func testQueryNoResult() throws {
        setupMockServiceForQueryTest()
        sut.viewDidLoad()

        sut.viewDidLoad()
        XCTAssertEqual(spy.items.count, 3)
        sut.query.onNext("ChSb")
        XCTAssertEqual(spy.items.count, 0)
    }

    func testQueryPartialName() throws {
        setupMockServiceForQueryTest()
        sut.viewDidLoad()

        sut.viewDidLoad()
        XCTAssertEqual(spy.items.count, 3)
        sut.query.onNext("iTc")
        XCTAssertEqual(spy.items.count, 2)
    }

    func testQuerySymbol() throws {
        setupMockServiceForQueryTest()
        sut.viewDidLoad()

        sut.viewDidLoad()
        XCTAssertEqual(spy.items.count, 3)
        sut.query.onNext("bTc")
        XCTAssertEqual(spy.items.count, 1)
    }

    func testQueryFullTicker() throws {
        setupMockServiceForQueryTest()
        sut.viewDidLoad()

        XCTAssertEqual(spy.items.count, 3)
        sut.query.onNext("btcusd")
        XCTAssertEqual(spy.items.count, 1)
    }

    func testQueryPartialTicker() throws {
        setupMockServiceForQueryTest()
        sut.viewDidLoad()

        XCTAssertEqual(spy.items.count, 3)
        sut.query.onNext("tcusd")
        XCTAssertEqual(spy.items.count, 2)
    }
}

// MARK: - Private

private extension CryptoMarketplaceTests {
    private func setupMockServiceForQueryTest() {
        mockService.symbols = [SymbolName(symbol: "bTC", name: "BTC"), SymbolName(symbol: "lTC", name: "ltC"), SymbolName(symbol: "Eth", name: "eth")]
        mockService.labels = [SymbolName(symbol: "BtC", name: "BiTcoin"), SymbolName(symbol: "lTC", name: "lItCoiN"), SymbolName(symbol: "Eth", name: "ethErEUm")]
        mockService.pairs = [TradingPair(ticker: "BtcuSd"), TradingPair(ticker: "LtcuSd"), TradingPair(ticker: "EThuSd")]
        mockService.tickers = [ticker1, ticker2, ticker3]
    }
}
