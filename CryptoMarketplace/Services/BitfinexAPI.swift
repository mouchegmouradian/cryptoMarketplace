//
//  BitfinexAPI.swift
//  CryptoMarketplace
//

import Moya

enum BitfinexAPI {
    case getPlatformStatus
    case getPairs
    case getSymbols
    case getLabels
    case getTickers(symbols: [String])
}

extension BitfinexAPI: TargetType {

    var baseURL: URL {
        return URL(string: "https://api-pub.bitfinex.com/v2")!
    }

    var path: String {
        switch self {
        case .getPlatformStatus: return "/platform/status"
        case .getPairs: return "/conf/pub:list:pair:exchange"
        case .getSymbols: return "/conf/pub:map:currency:sym"
        case .getLabels: return "/conf/pub:map:currency:label"
        case .getTickers: return "/tickers"
        }
    }

    var method: Method {
        switch self {
        case .getPlatformStatus: return .get
        case .getPairs: return .get
        case .getSymbols: return .get
        case .getLabels: return .get
        case .getTickers: return .get
        }
    }

    // Here we specify body parameters, objects, files etc or just do a plain request without a body.
    var task: Task {
        switch self {
        case .getPlatformStatus: return .requestPlain
        case .getPairs: return .requestPlain
        case .getSymbols: return .requestPlain
        case .getLabels: return .requestPlain
        case .getTickers(let symbols):
            let params: [String: Any] = ["symbols": symbols.joined(separator: ",")]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    // Used for testing
    var sampleData: Data {
        return Data()
    }
}
