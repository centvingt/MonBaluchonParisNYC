//
//  TranslationServiceTestCase.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 03/07/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class TranslationServiceTestCase: XCTestCase {
    var translationService: TranslationService!
    var expectation: XCTestExpectation!
    let timeOut = 1.0
    
    let queryText = "The Great Pyramid of Giza"
    let translatedText = "La grande pyramide de Gizeh"
    
    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession.init(configuration: configuration)

        translationService = TranslationService(
            session: session,
            apiURL: MockResponseData.goodURL
        )
        expectation = expectation(description: "Expectation")
    }
    
    func testGivenResponseAndDataAreCorrect_WhenGetTranslation_ThenResponseIsASuccess() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseOK,
                data: MockResponseData.translationCorrectData
            )
        }
        // When
        translationService.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, string in
            // Then
            XCTAssertNil(bpnError)
            XCTAssertNotNil(string)
            
            XCTAssertEqual(self.translatedText, string)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenRequestHasAUnknowdError_WhenGetTranslation_ThenUndefinedErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: MockResponseData.undefinedError,
                response: nil,
                data: nil
            )
        }
        
        // When
        translationService.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, string in
            // Then
            XCTAssertEqual(bpnError, .undefinedRequestError)
            XCTAssertNil(string)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenBadURL_WhenGetRate_ThenBadURLErrorIsThrown() {
        // Given
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession.init(configuration: configuration)

        translationService = TranslationService(
            session: session,
            apiURL: MockResponseData.badURL
        )

        // When
        translationService.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, string in
            // Then
            XCTAssertEqual(bpnError, .undefinedRequestError)
            XCTAssertNil(string)
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeOut)
    }

    func testGivenRequestHasConnectionError_WhenGetTranslation_ThenConnectionErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: MockResponseData.internetConnectionError,
                response: nil,
                data: nil
            )
        }
        // When
        translationService.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, string in
            // Then
            XCTAssertNotNil(bpnError)
            XCTAssertNil(string)

            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }

    func testGivenBadResponseData_WhenGetTranslation_ThenIncorrectDataErrorIsThrown() {
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseOK,
                data: MockResponseData.incorrectData
            )
        }
        translationService.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, string in
            // Then
            XCTAssertNotNil(bpnError)
            XCTAssertNil(string)

            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }

    func testGivenNoResponseData_WhenGetTranslation_ThenResponseDataErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseOK,
                data: nil
            )
        }
        // When
        translationService.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, string in
            // Then
            XCTAssertEqual(bpnError, .httpResponseData)
            XCTAssertNil(string)

            self.expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeOut)
    }

    func testGivenBadStatusResponse_WhenGetTranslation_ThenStatusCodeErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseKO,
                data: nil
            )
        }

        // When
        translationService.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, string in
            // Then
            XCTAssertEqual(bpnError, .httpStatusCode)
            XCTAssertNil(string)

            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    func testGivenNoResponse_WhenGetTranslation_ThenResponseErrorIsThrown() {
        // Givent
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: nil,
                data: nil
            )
        }

        // When
        translationService.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, string in
            // Then
            XCTAssertEqual(bpnError, .httpResponse)
            XCTAssertNil(string)

            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
 }
