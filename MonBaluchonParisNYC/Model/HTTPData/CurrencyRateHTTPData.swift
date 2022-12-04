//
//  CurrencyRateHTTPData.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

// OLD values
//struct CurrencyRateHTTPData: Decodable {
//    let success: Bool
//    let date: String
//    let rates: Rates
//
//    struct Rates: Decodable {
//        let USD: Double
//    }
//}

// New received JSON
//{
//  "amount": 1.0,
//  "base": "EUR",
//  "date": "2022-12-02",
//  "rates": {
//    "USD": 1.0538
//  }
//}

// New values
struct CurrencyRateHTTPData: Decodable {
    let date: String
    let rates: Rates
    
    struct Rates: Decodable {
        let USD: Double
    }
}
