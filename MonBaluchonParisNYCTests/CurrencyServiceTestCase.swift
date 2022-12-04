//
//  MonBaluchonParisNYCTests.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 12/06/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class CurrencyServiceTestCase: XCTestCase {
    var currencyService: CurrencyService!
    var expectation: XCTestExpectation!
    let timeOut = 1.0
    
    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession.init(configuration: configuration)
        
        currencyService = CurrencyService(
            session: session,
            apiURL: MockResponseData.goodURL
        )
        expectation = expectation(description: "Currency expectation")
    }
    
    func testGivenResponseAndDataAreCorrect_WhenGetRate_ThenResponseIsASuccess() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseOK,
                data: MockResponseData.currencyCorrectData
            )
        }
        // When
        currencyService.getRate { error, data in
            // Then
//            let success = true
            let date = "2021-06-14"
            let ratesUSD = 1.212437

            XCTAssertNil(error)
            XCTAssertNotNil(data)

//            XCTAssertEqual(success, data?.success)
            XCTAssertEqual(date, data?.date)
            XCTAssertEqual(ratesUSD, data?.rates.USD)

            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }

    func testGivenRequestHasAUnknowdError_WhenGetRate_ThenUndefinedErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: MockResponseData.undefinedError,
                response: nil,
                data: nil
            )
        }
        
        // When
        currencyService.getRate { error, data in
            // Then
            XCTAssertEqual(error, .undefinedRequestError)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenBadURL_WhenGetRate_ThenBadURLErrorIsThrown() {
        // Given
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession.init(configuration: configuration)
        
        currencyService = CurrencyService(
            session: session,
            apiURL: MockResponseData.badURL
        )
        
        // When
        currencyService.getRate { error, data in
            // Then

            XCTAssertEqual(error, .apiURLRequest)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenRequestHasConnectionError_WhenGetRate_ThenConnectionErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: MockResponseData.internetConnectionError,
                response: nil,
                data: nil
            )
        }
        // When
        currencyService.getRate { error, data in
            // Then

            XCTAssertEqual(error, .internetConnection)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testGivenBadResponseData_WhenGetRate_ThenIncorrectDataErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseOK,
                data: MockResponseData.incorrectData
            )
        }
        
        // When
        currencyService.getRate { error, data in
            // Then

            XCTAssertNotNil(error)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenNoResponseData_WhenGetRate_ThenResponseDataErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseOK,
                data: nil
            )
        }
        // When
        currencyService.getRate { error, data in
            // Then
            XCTAssertEqual(error, .httpResponseData)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeOut)
    }

    func testGivenBadStatusResponse_WhenGetRate_ThenStatusCodeErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseKO,
                data: nil
            )
        }
        
        // When
        currencyService.getRate { error, data in
            // Then

            XCTAssertEqual(error, .httpStatusCode)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    func testGivenNoResponse_WhenGetRate_ThenResponseErrorIsThrown() {
        // Giventm
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: nil,
                data: nil
            )
        }
        
        // When
        currencyService.getRate { error, data in
            // Then

            XCTAssertEqual(error, .httpResponse)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
}
