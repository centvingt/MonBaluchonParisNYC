//
//  TranslationTestCase.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 03/07/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class TranslationTestCase: XCTestCase {
    var sut = Translation()
    
    var expectation: XCTestExpectation!
    let timeOut = 1.0
    
    var userDefaults = MockUserDefaults()
    var translationService = MockTranslationService()
    
    let requestTimestampCounterUDKey = "translationRequestTimestampCounter"
    let requestCounterUDKey = "translationRequestCounter"
    
    let queryText = "The Great Pyramid of Giza"
    let translatedText = "La grande pyramide de Gizeh"
    
    override func setUp() {
        super.setUp()
        
        userDefaults = MockUserDefaults()
        translationService = MockTranslationService()
        
        sut = Translation(
            userDefaults: userDefaults,
            translationService: translationService
        )
        
        expectation = expectation(description: "Expectation")
    }
    
    // MARK: - Request limit tests
    
    func testGivenCurrentDateIsEqualToTimestampCounterAndCounterIsNotMax_WhenGetTranslation_ThenNoError() {
        // Given
        currentDate = .mockDate20210403
        
        let timestamp = Int(currentDate.value().timeIntervalSince1970)
        userDefaults.set(timestamp, forKey: requestTimestampCounterUDKey)
        
        let requestCounter = sut.maxRequestPerDay - 1
        userDefaults.set(requestCounter, forKey: requestCounterUDKey)
        
        translationService.bpnError = nil
        translationService.response = translatedText
        
        // When
        sut.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, translatedText in
            // Then
            XCTAssertNil(bpnError)
            XCTAssertNotNil(translatedText)
            
            XCTAssertEqual(self.translatedText, translatedText)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenCurrentDateIsEqualToTimestampCounterAndCounterIsMax_WhenGetTranslation_ThenError() {
        // Given
        currentDate = .mockDate20210403
        
        let timestamp = Int(currentDate.value().timeIntervalSince1970)
        userDefaults.set(timestamp, forKey: requestTimestampCounterUDKey)
        
        let requestCounter = sut.maxRequestPerDay
        userDefaults.set(requestCounter, forKey: requestCounterUDKey)
        
        translationService.bpnError = .translationRequestLimitExceeded
        translationService.response = nil
        
        // When
        sut.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, translatedText in
            // Then
            XCTAssertEqual(bpnError, .translationRequestLimitExceeded)
            XCTAssertNil(translatedText)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenCurrentDateIsEqualToTimestampCounter_WhenGetTranslation_ThenNoError() {
        // Given
        currentDate = .mockDate20210403
        
        let timestamp = Int(currentDate.value().timeIntervalSince1970)
        userDefaults.set(timestamp, forKey: requestTimestampCounterUDKey)
        
        translationService.bpnError = nil
        translationService.response = translatedText
        
        // When
        sut.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, translatedText in
            // Then
            XCTAssertNil(bpnError)
            XCTAssertNotNil(translatedText)
            
            XCTAssertEqual(self.translatedText, translatedText)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    
    func testGivenCurrentDateIsGreaterThanTimestampCounter_WhenGetTranslation_ThenRequestCounterIsReset() {
        // Given
        currentDate = .mockDate20210511
        
        let userDefaultsDate = CurrentDate.mockDate20210403
        
        let timestamp = Int(userDefaultsDate.value().timeIntervalSince1970)
        userDefaults.set(timestamp, forKey: requestTimestampCounterUDKey)
        
        translationService.bpnError = nil
        translationService.response = translatedText
        
        // When
        sut.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, translatedText in
            // Then
            XCTAssertNil(bpnError)
            XCTAssertNotNil(translatedText)
            
            XCTAssertEqual(self.translatedText, translatedText)
            
            XCTAssertEqual(
                self.userDefaults.integer(forKey: self.requestCounterUDKey),
                0
            )
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenCurrentDateIsLowerThanTimestampCounter_WhenGetTranslation_ThenError() {
        // Given
        currentDate = .mockDate20210403
        
        let userDefaultsDate = CurrentDate.mockDate20210511
        
        let timestamp = Int(userDefaultsDate.value().timeIntervalSince1970)
        userDefaults.set(timestamp, forKey: requestTimestampCounterUDKey)
        
        translationService.bpnError = .translationRequestLimitExceeded
        translationService.response = nil
        
        // When
        sut.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, translatedText in
            // Then
            XCTAssertEqual(bpnError, .translationRequestLimitExceeded)
            XCTAssertNil(translatedText)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }

    func testGivenNoUDTimestamp_WhenGetTranslation_ThenNoError() {
        // Given
        userDefaults.set(0, forKey: requestTimestampCounterUDKey)
        
        translationService.bpnError = nil
        translationService.response = translatedText
        
        // When
        sut.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, translatedText in
            // Then
            XCTAssertNil(bpnError)
            XCTAssertNotNil(translatedText)
            
            XCTAssertEqual(self.translatedText, translatedText)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    // MARK: - Service error tests
    
    func testGivenNoInternetConnection_WhenGetTranslation_ThenError() {
        // Given
        translationService.bpnError = .internetConnection
        translationService.response = nil

        // When
        sut.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, translatedText in
            // Then
            XCTAssertEqual(bpnError, .internetConnection)
            XCTAssertNil(translatedText)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenUndefinedError_WhenGetTranslation_ThenError() {
        // Given
        translationService.bpnError = .undefinedRequestError
        translationService.response = nil

        // When
        sut.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, translatedText in
            // Then
            XCTAssertEqual(bpnError, .undefinedRequestError)
            XCTAssertNil(translatedText)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenNoErrorAndNoString_WhenGetTranslation_ThenError() {
        // Given
        translationService.response = nil

        // When
        sut.getTranslation(
            of: queryText,
            from: .en,
            to: .fr
        ) { bpnError, translatedText in
            // Then
            XCTAssertNil(translatedText)
            
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeOut)
    }
}
