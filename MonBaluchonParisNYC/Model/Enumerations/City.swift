//
//  City.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 03/06/2021.
//

import Foundation

enum City {
    case paris, nyc
    
    func getCurrency() -> (name: String, convertSymbol: String) {
        switch self {
        case .paris:
            return ("euro", "$")
        case .nyc:
            return ("dollar", "€")
        }
    }
}
