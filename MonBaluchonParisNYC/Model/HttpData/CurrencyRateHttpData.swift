//
//  CurrencyRateHttpData.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

struct CurrencyRateHttpData: Decodable {
    let success: Bool
    let date: String
    let rates: Rates
    
    struct Rates: Decodable {
        let USD: Float
    }
}
