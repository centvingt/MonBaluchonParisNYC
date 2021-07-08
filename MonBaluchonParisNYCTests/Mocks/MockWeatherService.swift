//
//  MockWeatherService.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 08/07/2021.
//

@testable import MonBaluchonParisNYC

class MockWeatherService: WeatherServiceProtocol {
    var bpnError: BPNError?
    var weatherHTTPData: WeatherHTTPData?
    
    func getWeatherOf(
        city: City,
        completion: @escaping (BPNError?, WeatherHTTPData?) -> ()
    ) {
        completion(bpnError, weatherHTTPData)
    }
}
