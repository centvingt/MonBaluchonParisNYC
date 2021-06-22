//
//  CurrencyIOValues .swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 08/06/2021.
//

import Foundation

struct CurrencyIOValues: Equatable {
    let input: String
    let output: [String]
    
    init(
        input: String,
        output: [String]
    ) {
        self.input = input
        self.output = output
    }
    
    init(for calulation: CurrencyCalculation) {
        switch calulation {
        case .usdToEuro:
            input = "0 $"
            output = ["0 €"]
        case .euroToUSD:
            input = "0 €"
            output = ["0 $"]
        case .vat:
            input = "0 $"
            output = ["0 $"]
        case .tip:
            input = "0 $"
            output = ["0 $", "0 $"]
        }
    }
}
