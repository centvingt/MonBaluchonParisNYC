//
//  City.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 03/06/2021.
//

import Foundation

enum City: String {
    case paris = "Paris",
         nyc = "New-York"
    
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
    
    func getCityWeatherID() -> Int64 {
        switch self {
        case .paris:
            return 2988507
        case .nyc:
            return 5128581
        }
    }
}
