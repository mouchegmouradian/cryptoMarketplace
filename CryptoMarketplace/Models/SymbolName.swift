//
//  SymbolName.swift
//  CryptoMarketplace
//

import Foundation

// MARK: - SymbolNameWrapper

struct SymbolNameWrapper {
    let symbols: [SymbolName]
}

// MARK: Codable

extension SymbolNameWrapper: Codable {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var data: [SymbolName] = []

        while !container.isAtEnd {
            if let value = try? container.decode(SymbolName.self) {
                data.append(value)
            }
        }

        symbols = data
    }
}


// MARK: - SymbolName

struct SymbolName {
    let symbol: String
    let name: String

    init(symbol: String, name: String) {
        self.symbol = symbol.uppercased()
        self.name = name.uppercased()
    }
}

// MARK: Codable

extension SymbolName: Codable {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        symbol = try container.decode(String.self)
        name = try container.decode(String.self)
    }
}
