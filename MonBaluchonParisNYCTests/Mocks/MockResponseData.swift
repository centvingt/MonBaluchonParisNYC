//
//  MockResponseData.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 03/07/2021.
//

import Foundation

class MockResponseData {
    // MARK: - Simulate URL
    
    static let goodURL = "https://www.apple.com/fr/"
    static let badURL = "bar url"
    
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
    static let undefinedError = URLError(.cannotFindHost)

    // MARK: - Simulate data
    static var currencyCorrectData: Data? {
        let bundle = Bundle(for: MockResponseData.self)
        let url = bundle.url(forResource: "Currency", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    static var translationCorrectData: Data? {
        let bundle = Bundle(for: MockResponseData.self)
        let url = bundle.url(forResource: "Translation", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    static var weatherCorrectData: Data? {
        let bundle = Bundle(for: MockResponseData.self)
        let url = bundle.url(forResource: "Weather", withExtension: "json")!
        return try! Data(contentsOf: url)
    }

    static let incorrectData = "incorrect data".data(using: .utf8)!
}
