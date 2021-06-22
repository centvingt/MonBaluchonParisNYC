//
//  MonBaluchonParisNYCTests.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 12/06/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class CurrencyServiceTestCase: XCTestCase {

//    MARK: - Not iOS 13.0 friendly

//    func testGetQuoteShouldPostFailedCallbackIfError() {
//        // Given
//        let currencyService = CurrencyService(
//            session: URLSessionFake(
//                data: nil,
//                response: nil,
//                error: MockCurrencyData.error
//            )
//        )
//
//        // When
//        let expectation = XCTestExpectation(description: "Wait for queue change.")
//        currencyService.getRate { error, data in
//            // Then
//            XCTAssertNotNil(error)
//            XCTAssertNil(data)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.01)
//    }
//
//    func testGetQuoteShouldPostFailedCallbackIfNoData() {
//        // Given
//        let currencyService = CurrencyService(
//            session: URLSessionFake(
//                data: nil,
//                response: nil,
//                error: nil
//            )
//        )
//
//        // When
//        let expectation = XCTestExpectation(description: "Wait for queue change.")
//        currencyService.getRate { error, data in
//            // Then
//            XCTAssertNotNil(error)
//            XCTAssertNil(data)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.01)
//    }
//
//    func testGetQuoteShouldPostFailedCallbackIfIncorrectResponse() {
//        // Given
//        let currencyService = CurrencyService(
//            session: URLSessionFake(
//                data: MockCurrencyData.currencyCorrectData,
//                response: MockCurrencyData.responseKO,
//                error: nil
//            )
//        )
//
//        // When
//        let expectation = XCTestExpectation(description: "Wait for queue change.")
//        currencyService.getRate { error, data in
//            // Then
//            XCTAssertNotNil(error)
//            XCTAssertNil(data)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.01)
//    }
//
//    func testGetQuoteShouldPostFailedCallbackIfIncorrectData() {
//        // Given
//        let currencyService = CurrencyService(
//            session: URLSessionFake(
//                data: MockCurrencyData.incorrectData,
//                response: MockCurrencyData.responseOK,
//                error: nil
//            )
//        )
//
//        // When
//        let expectation = XCTestExpectation(description: "Wait for queue change.")
//        currencyService.getRate { error, data in
//            // Then
//            XCTAssertNotNil(error)
//            XCTAssertNil(data)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.01)
//    }
//
//    func testGetQuoteShouldPostFailedCallbackIfNoErrorAndCorrectData() {
//        // Given
//        let currencyService = CurrencyService(
//            session: URLSessionFake(
//                data: MockCurrencyData.currencyCorrectData,
//                response: MockCurrencyData.responseOK,
//                error: nil
//            )
//        )
//
//        // When
//        let expectation = XCTestExpectation(description: "Wait for queue change.")
//        currencyService.getRate { error, data in
//            // Then
//            let success = true
//            let date = "2021-06-14"
//            let ratesUSD = 1.212437
//
//            XCTAssertNil(error)
//            XCTAssertNotNil(data)
//
//            XCTAssertEqual(success, data?.success)
//            XCTAssertEqual(date, data?.date)
//            XCTAssertEqual(ratesUSD, data?.rates.USD)
//
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.01)
//    }
//
    //    MARK: - iOS 13.0 friendly
    
    var currencyService: CurrencyService!
    var expectation: XCTestExpectation!
    let timeOut = 1.0

    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession.init(configuration: configuration)

        currencyService = CurrencyService(
            session: session,
            apiURL: MockCurrencyData.goodURL
        )
        expectation = expectation(description: "Expectation")
    }

    func testGivenResponseAndDataAreCorrect_WhenGetRate_ThenResponseIsASuccess() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockCurrencyData.responseOK,
                data: MockCurrencyData.currencyCorrectData
            )
        }
        // When
        currencyService.getRate { error, data in
            // Then
            let success = true
            let date = "2021-06-14"
            let ratesUSD = 1.212437

            XCTAssertNil(error)
            XCTAssertNotNil(data)

            XCTAssertEqual(success, data?.success)
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
                error: MockCurrencyData.undefinedError,
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
            apiURL: MockCurrencyData.badURL
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
                error: MockCurrencyData.internetConnectionError,
                response: nil,
                data: nil
            )
        }
        // When
        currencyService.getRate { error, data in
            // Then

            XCTAssertNotNil(error)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testGivenBadResponseData_WhenGetRate_ThenIncorrectDataErrorIsThrown() {
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockCurrencyData.responseOK,
                data: MockCurrencyData.incorrectData
            )
        }
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
                response: MockCurrencyData.responseOK,
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
                response: MockCurrencyData.responseKO,
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
        // Givent
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
