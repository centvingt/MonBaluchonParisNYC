//
//  MockCurrencyService.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 19/06/2021.
//

@testable import MonBaluchonParisNYC

class MockCurrencyService: CurrencyServiceProtocol {
    var bpnError: BPNError?
    var currencyRateHTTPData: CurrencyRateHTTPData?
    
    func getRate(completion: @escaping (BPNError?, CurrencyRateHTTPData?) -> ()) {
        completion(bpnError, currencyRateHTTPData)
    }
}
