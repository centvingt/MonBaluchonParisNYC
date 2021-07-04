//
//  City.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 03/06/2021.
//

import Foundation

enum City: String {
    case paris, nyc
    
    var language: (
        from: TranslationLanguage,
        to: TranslationLanguage
    ) {
        switch self {
        case .paris:
            return (.fr, .en)
        case .nyc:
            return (.en, .fr)
        }
    }
    
    func getCurrency() -> (name: String, convertSymbol: String) {
        switch self {
        case .paris:
            return ("euro", "$")
        case .nyc:
            return ("dollar", "€")
        }
    }
}
