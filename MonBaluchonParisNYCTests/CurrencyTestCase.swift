//
//  CurrencyTestCase.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 17/06/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class CurrencyTestCase: XCTestCase {
    var sut = Currency()
    
    var userDefaults = MockUserDefaults()
    var currencyService = MockCurrencyService()
    
    var euroToUSDRate: String?
    var usdToEuroRate: String?
    var rateDate: String?
    
    var usdToEuroIOValues = CurrencyIOValues(for: .usdToEuro)
    var euroToUSDIOValues = CurrencyIOValues(for: .euroToUSD)
    var vatIOValues = CurrencyIOValues(for: .vat)
    var tipIOValues = CurrencyIOValues(for: .tip)
    
    let euroToUSDRateUDKey = "euroToUSDRate"
    let currencyDateUDKey = "currencyDate"
    let usdToEuroInputUDKey = "usdToEuroInput"
    let euroToUSDInputUDKey = "euroToUSDInput"
    let vatInputUDKey = "vatInput"
    let tipInputUDKey = "tipInput"
    
    let timeout = 0.1
    
    // Check that a notification has been posted
    var notification: NSNotification?
    
    // setUp() is executed for each test
    override func setUp() {
        super.setUp()
        
        userDefaults = MockUserDefaults()
        currencyService = MockCurrencyService()
        
        sut = Currency(
            userDefaults: userDefaults,
            currencyService: currencyService
        )
        
        notification = nil
    }
    
    /* notificationPosted() is executed
     when a notification is observed */
    @objc func notificationPosted(_ notification: NSNotification) {
        self.notification = notification
        
        if notification.name == .currencyRateData {
            guard let euroToUSDRate = notification
                    .userInfo?["euroToUSDRate"] as? String,
                  let usdToEuroRate = notification
                    .userInfo?["usdToEuroRate"] as? String,
                  let rateDate = notification
                    .userInfo?["rateDate"] as? String,
                  let usdToEuroIOValues = notification
                    .userInfo?["usdToEuroIOValues"] as? CurrencyIOValues,
                  let euroToUSDIOValues = notification
                    .userInfo?["euroToUSDIOValues"] as? CurrencyIOValues,
                  let vatIOValues = notification
                    .userInfo?["vatIOValues"] as? CurrencyIOValues,
                  let tipIOValues = notification
                    .userInfo?["tipIOValues"] as? CurrencyIOValues
            else { return }
            
            self.euroToUSDRate = euroToUSDRate
            self.usdToEuroRate = usdToEuroRate
            self.rateDate = rateDate
            self.usdToEuroIOValues = usdToEuroIOValues
            self.euroToUSDIOValues = euroToUSDIOValues
            self.vatIOValues = vatIOValues
            self.tipIOValues = tipIOValues
        }
    }

    func testGivenGetRateReturnConnectionError_WhenGetRate_ThenNotificationPosted() {
        // Given
        currentDate = .mockDate20210403
        userDefaults.set(20210402, forKey: "currencyDate")
        
        currencyService.bpnError = .internetConnection
        currencyService.currencyRateHTTPData = nil
        
        // When
        let notificationName = Notification.Name.errorInternetConnection
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getRate()
        
        // Then
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssertEqual(self.notification?.name, .errorInternetConnection)
        }
    }
    
    func testGivenGetRateReturnUndefinedError_WhenGetRate_ThenNotificationPosted() {
        // Given
        currencyService.bpnError = .undefinedRequestError
        currencyService.currencyRateHTTPData = nil
        
        // When
        let notificationName = Notification.Name.errorUndefined
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getRate()
        
        // Then
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssertEqual(self.notification?.name, .errorUndefined)
        }
    }
    
    func testGivenGetRateReturnNoData_WhenGetRate_ThenNotificationPosted() {
        // Given
        currencyService.bpnError = nil
        currencyService.currencyRateHTTPData = nil
        
        // When
        let notificationName = Notification.Name.errorUndefined
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getRate()
        
        // Then
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssertEqual(self.notification?.name, .errorUndefined)
        }
    }
    
    func testGivenEmptyUD_WhenGetRate_ThenUDSetAndNotificationPosted() {
        // Given
        let currencyRateHTTPData = CurrencyRateHTTPData(
            success: true,
            date: "2021-10-03",
            rates: CurrencyRateHTTPData.Rates(USD: 2.0)
        )
        
        currencyService.bpnError = nil
        currencyService.currencyRateHTTPData = currencyRateHTTPData
        
        // When
        let notificationName = Notification.Name.currencyRateData
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getRate()
        
        // Then
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            
            XCTAssertEqual(self.notification?.name, .currencyRateData)
            
            XCTAssertEqual(self.euroToUSDRate, "2,000")
            XCTAssertEqual(self.usdToEuroRate, "0,500")
            XCTAssertEqual(self.rateDate, "dimanche 3 octobre 2021")
            XCTAssertEqual(
                self.usdToEuroIOValues,
                CurrencyIOValues(
                    input: "0 $",
                    output: ["0,000 €"]
                )
            )
            XCTAssertEqual(
                self.euroToUSDIOValues,
                CurrencyIOValues(
                    input: "0 €",
                    output: ["0,000 $"]
                )
            )
            XCTAssertEqual(
                self.vatIOValues,
                CurrencyIOValues(
                    input: "0 $",
                    output: ["0,000 $"]
                )
            )
            XCTAssertEqual(
                self.tipIOValues,
                CurrencyIOValues(
                    input: "0 $",
                    output: ["0,000 $", "0,000 $"]
                )
            )
        }
    }
    
    func testGivenUDIsSet_WhenGetRate_ThenUDSetAndNotificationPosted() {
        // Given
        userDefaults.set(3.0, forKey: euroToUSDRateUDKey)
        userDefaults.set(211002, forKey: currencyDateUDKey)
        
        print("CurrencyTestCase ~> userDefaults.string euroToUSDRate ~>", userDefaults.double(forKey: "euroToUSDRate"))
        
        let currencyRateHTTPData = CurrencyRateHTTPData(
            success: true,
            date: "2021-10-03",
            rates: CurrencyRateHTTPData.Rates(USD: 2.0)
        )
        
        currencyService.bpnError = nil
        currencyService.currencyRateHTTPData = currencyRateHTTPData
        
        // When
        let notificationName = Notification.Name.currencyRateData
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getRate()
        
        // Then
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            
            XCTAssertEqual(
                self.userDefaults.double(forKey: self.euroToUSDRateUDKey),
                2.0
            )
            XCTAssertEqual(
                self.userDefaults.integer(forKey: self.currencyDateUDKey),
                20211003
            )
            
            XCTAssertEqual(self.notification?.name, .currencyRateData)
            
            XCTAssertEqual(self.euroToUSDRate, "2,000")
            XCTAssertEqual(self.usdToEuroRate, "0,500")
            XCTAssertEqual(self.rateDate, "dimanche 3 octobre 2021")
            XCTAssertEqual(
                self.usdToEuroIOValues,
                CurrencyIOValues(
                    input: "0 $",
                    output: ["0,000 €"]
                )
            )
            XCTAssertEqual(
                self.euroToUSDIOValues,
                CurrencyIOValues(
                    input: "0 €",
                    output: ["0,000 $"]
                )
            )
            XCTAssertEqual(
                self.vatIOValues,
                CurrencyIOValues(
                    input: "0 $",
                    output: ["0,000 $"]
                )
            )
            XCTAssertEqual(
                self.tipIOValues,
                CurrencyIOValues(
                    input: "0 $",
                    output: ["0,000 $", "0,000 $"]
                )
            )
        }
    }
    
    func testGivenUDIsSetWithBadData_WhenGetRate_NotificationPosted() {
        // Given
        userDefaults.set(20211002, forKey: currencyDateUDKey)
        currentDate = .mockDate20211002
        
        /* Bad data in User Defaults */
        userDefaults.set(nil, forKey: euroToUSDRateUDKey)
        
        // When
        let notificationName = Notification.Name.errorUndefined
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getRate()
        
        // Then
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssertEqual(self.notification?.name, .errorUndefined)
        }
    }
}


extension CurrentDate {
    static let mockDate20210403 = CurrentDate(
        value: {
            // 03/04/2021 0h00.00
            return Date(timeIntervalSince1970: 1617408000)
        }
    )
    static let mockDate20211002 = CurrentDate(
        value: {
            // 02/10/2021 0h00.00
            return Date(timeIntervalSince1970: 1633132800)
        }
    )
    static let mockDate20210511 = CurrentDate(
        value: {
            // 11/05/2021 0h00.00
            return Date(timeIntervalSince1970: 1620691200)
        }
    )
}
