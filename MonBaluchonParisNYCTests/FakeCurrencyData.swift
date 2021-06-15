//
//  FakeCurrencyData.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 14/06/2021.
//

import Foundation

class FakeCurrencyData {
    // MARK: - Simulate URL
    
    static let goodURL = "https://www.apple.com/fr/"
    static let badURL = ""
    
    // MARK: - Simulate response
    static let responseOK = HTTPURLResponse(
        url: URL(string: goodURL)!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: [:]
    )!
    static let responseKO = HTTPURLResponse(
        url: URL(string: goodURL)!,
        statusCode: 500,
        httpVersion: nil,
        headerFields: [:]
    )!
    static let responseWithBadURL = HTTPURLResponse(
        url: URL(string: badURL)!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: [:]
    )!
    static let responseWithConnectionError = HTTPURLResponse(
        url: URL(string: badURL)!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: [:]
    )!

    // MARK: - Simulata error
    class FakeResponseDataError: Error {}
    static let error = FakeResponseDataError()
    static let internetConnectionError = URLError(.notConnectedToInternet)
    static let urlError = URLError(.cannotFindHost)

    // MARK: - Simulate data
    static var currencyCorrectData: Data? {
        let bundle = Bundle(for: FakeCurrencyData.self)
        let url = bundle.url(forResource: "Currency", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    static let incorrectData = "incorrect data".data(using: .utf8)!
}
