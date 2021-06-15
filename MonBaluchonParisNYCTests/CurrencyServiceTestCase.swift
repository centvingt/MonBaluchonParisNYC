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
//                error: FakeCurrencyData.error
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
//                data: FakeCurrencyData.currencyCorrectData,
//                response: FakeCurrencyData.responseKO,
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
//                data: FakeCurrencyData.incorrectData,
//                response: FakeCurrencyData.responseOK,
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
//                data: FakeCurrencyData.currencyCorrectData,
//                response: FakeCurrencyData.responseOK,
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
            apiURL: FakeCurrencyData.goodURL
        )
        expectation = expectation(description: "Expectation")
    }

    func testSuccessResponse() {
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: FakeCurrencyData.responseOK,
                data: FakeCurrencyData.currencyCorrectData
            )
        }
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

    func testError() {
        MockURLProtocol.requestHandler = { request in
            return (
                error: FakeCurrencyData.urlError,
                response: nil,
                data: nil
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

    func testConnectionError() {
        
        MockURLProtocol.requestHandler = { request in
            return (
                error: FakeCurrencyData.internetConnectionError,
                response: nil,
                data: nil
            )
        }
        currencyService.getRate { error, data in
            // Then

            XCTAssertNotNil(error)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testBadData() {
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: FakeCurrencyData.responseOK,
                data: FakeCurrencyData.incorrectData
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

    func testNoData() {
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: FakeCurrencyData.responseOK,
                data: nil
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

    func testBadResponse() {
        print("---")
        print("testBadResponse")
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: FakeCurrencyData.responseKO,
                data: nil
            )
        }
        currencyService.getRate { error, data in
            // Then

            XCTAssertNotNil(error)
            XCTAssertNil(data)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
        print("---")
    }
    func testNoResponse() {
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: nil,
                data: nil
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

    func testBadURL() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession.init(configuration: configuration)

        currencyService = CurrencyService(
            session: session,
            apiURL: FakeCurrencyData.badURL
        )
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: nil,
                data: nil
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
}
