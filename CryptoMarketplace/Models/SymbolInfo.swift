//
//  SymbolInfo.swift
//  CryptoMarketplace
//

import Foundation

struct SymbolInfo: Equatable {
    let apiSymbol: String
    let realSymbol: String
    let name: String

    init(apiSymbol: String, realSymbol: String, name: String) {
        self.apiSymbol = apiSymbol.uppercased()
        self.realSymbol = realSymbol.uppercased()
        self.name = name.uppercased()
    }
}
