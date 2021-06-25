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
    var pasteboardService = MockPasteboardService()
    
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
    
    let timeout = 1.0
    
    // Check that a notification has been posted
    var notification: NSNotification?
    
    // setUp() is executed for each test
    override func setUp() {
        super.setUp()
        
        userDefaults = MockUserDefaults()
        currencyService = MockCurrencyService()
        pasteboardService = MockPasteboardService()
        
        sut = Currency(
            userDefaults: userDefaults,
            currencyService: currencyService,
            pasteboardService: pasteboardService
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

    // MARK: - Request tests
    
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
    
    func testHTTPDataDateIsZero_WhenGetRate_ThenErrorNotificationPosted() {
        let notificationName = Notification.Name.errorUndefined
        let currencyRateHTTPData = CurrencyRateHTTPData(
            success: true,
            date: "0",
            rates: CurrencyRateHTTPData.Rates(USD: 2.0)
        )
        
        currencyService.bpnError = nil
        currencyService.currencyRateHTTPData = currencyRateHTTPData
        
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
        
        // When
        sut.getRate()
        
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            
            // Then
            XCTAssertEqual(self.notification?.name, .errorUndefined)
            XCTAssertEqual(self.rateDate, nil)
        }
    }
    
    func testHTTPDataDateIsBad_WhenGetRate_ThenErrorNotificationPosted() {
        let notificationName = Notification.Name.errorUndefined
        let currencyRateHTTPData = CurrencyRateHTTPData(
            success: true,
            date: "aze",
            rates: CurrencyRateHTTPData.Rates(USD: 2.0)
        )
        
        currencyService.bpnError = nil
        currencyService.currencyRateHTTPData = currencyRateHTTPData
        
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
        
        // When
        sut.getRate()
        
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            
            // Then
            XCTAssertEqual(self.notification?.name, .errorUndefined)
            XCTAssertEqual(self.rateDate, nil)
        }
    }

    // MARK: - User Defaults tests
    
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
        
        userDefaults.set("2 $", forKey: usdToEuroInputUDKey)
        userDefaults.set("3 €", forKey: euroToUSDInputUDKey)
        userDefaults.set("4 $", forKey: vatInputUDKey)
        userDefaults.set("5 $", forKey: tipInputUDKey)
        
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
            XCTAssertEqual(
                self.userDefaults.string(forKey: self.usdToEuroInputUDKey),
                "2 $"
            )
            XCTAssertEqual(
                self.userDefaults.string(forKey: self.euroToUSDInputUDKey),
                "3 €"
            )
            XCTAssertEqual(
                self.userDefaults.string(forKey: self.vatInputUDKey),
                "4 $"
            )
            XCTAssertEqual(
                self.userDefaults.string(forKey: self.tipInputUDKey),
                "5 $"
            )
            
            XCTAssertEqual(self.notification?.name, .currencyRateData)
            
            XCTAssertEqual(self.euroToUSDRate, "2,000")
            XCTAssertEqual(self.usdToEuroRate, "0,500")
            XCTAssertEqual(self.rateDate, "dimanche 3 octobre 2021")
            XCTAssertEqual(
                self.usdToEuroIOValues,
                CurrencyIOValues(
                    input: "2 $",
                    output: ["1,000 €"]
                )
            )
            XCTAssertEqual(
                self.euroToUSDIOValues,
                CurrencyIOValues(
                    input: "3 €",
                    output: ["6,000 $"]
                )
            )
            XCTAssertEqual(
                self.vatIOValues,
                CurrencyIOValues(
                    input: "4 $",
                    output: ["4,355 $"]
                )
            )
            XCTAssertEqual(
                self.tipIOValues,
                CurrencyIOValues(
                    input: "5 $",
                    output: ["5,750 $", "6,000 $"]
                )
            )
        }
    }
    
    func testGivenUDIsSetWithBadData_WhenGetRate_ThenNotificationPosted() {
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
    

    
    // MARK: - IO values tests
    
    func testGivenEmptyInputValue_WhenNotificationDataPosted_ThenOutputValueIsZero() {
        // Given
        userDefaults.set(" $", forKey: usdToEuroInputUDKey)
        
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
                self.usdToEuroIOValues,
                CurrencyIOValues(
                    input: " $",
                    output: ["0,000 €"]
                )
            )
        }
    }

    func testGivenOutput_WhenGetRate_ThenUDSetAndNotificationPosted() {
        // Given
        userDefaults.set("badvalue", forKey: usdToEuroInputUDKey)
//
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
                self.euroToUSDIOValues,
                CurrencyIOValues(input: "0 €", output: ["0,000 $"])
            )
        }
    }
    
    func testGivenNoEuroToRateData_WhenProcessInput_ThenReturnUserInputAndZeroOutput() {
        // Given
        userDefaults.set(nil, forKey: euroToUSDRateUDKey)
        
        // When
        let currencyIOValues = sut.processInput(
            input: "1,000 $",
            for: .usdToEuro
        )
        
        // Then
        XCTAssertEqual(
            currencyIOValues,
            CurrencyIOValues(
                input: "1,000 $",
                output: ["0 €"]
            )
        )
    }
    
    func testGivenUserInputStartWithDoubleZero_WhenProcessInput_ThenReturnZeroInputAndZeroOutput() {
        // Given
        let userInput = "00 $"
        
        // When
        let currencyIOValues = sut.processInput(
            input: userInput,
            for: .usdToEuro
        )
        
        // Then
        XCTAssertEqual(
            currencyIOValues,
            CurrencyIOValues(
                input: "0 $",
                output: ["0 €"]
            )
        )
    }
    
    func testGivenEmptyUserInput_WhenProcessInput_ThenReturnZeroInputAndZeroOutput() {
        // Given
        let userInput = " $"
        
        // When
        let currencyIOValues = sut.processInput(
            input: userInput,
            for: .usdToEuro
        )
        
        // Then
        XCTAssertEqual(
            currencyIOValues,
            CurrencyIOValues(
                input: "0 $",
                output: ["0 €"]
            )
        )
    }
    
    func testGivenUserInputHasFourFractionDigits_WhenProcessInput_ThenReturnZeroInputAndZeroOutput() {
        // Given
        let userInput = "0,0000 $"
        
        // When
        let currencyIOValues = sut.processInput(
            input: userInput,
            for: .usdToEuro
        )
        
        // Then
        XCTAssertEqual(
            currencyIOValues,
            CurrencyIOValues(
                input: "0,000 $",
                output: ["0 €"]
            )
        )
    }
    
    func testGivenCurrencyIOValuesAreSet_WhenDeleteInput_ThenReturnZeroInputAndZeroOutputAndUDIsNil() {
        // Given
        userDefaults.set(
            "2,000 $",
            forKey: usdToEuroInputUDKey
        )

        // When
        let newCurrencyIOValues = sut.deleteInput(for: .usdToEuro)

        // Then
        XCTAssertEqual(
            newCurrencyIOValues,
            CurrencyIOValues(input: "0 $", output: ["0 €"])
        )
        XCTAssertEqual(
            userDefaults.string(forKey: euroToUSDInputUDKey),
            nil
        )
    }
    
    func testGivenUserInputOverflow_WhenProcessInput_ThenReturnOldValue() {
        // Given
        userDefaults.set("100 000 $", forKey: usdToEuroInputUDKey)
        let userInput = "100 0000 $"
        
        // When
        let currencyIOValues = sut.processInput(
            input: userInput,
            for: .usdToEuro
        )
        
        // Then
        XCTAssertEqual(
            currencyIOValues.input, "100 000 $"
        )
    }
    
    func testGivenUserInputHasFourDigits_WhenProcessInput_ThenSpaceIsAdded() {
        // Given
        let userInput = "1000 $"
        
        // When
        let currencyIOValues = sut.processInput(
            input: userInput,
            for: .usdToEuro
        )
        
        // Then
        XCTAssertEqual(
            currencyIOValues.input, "1 000 $"
        )
    }
    
    func testGivenUserInputHasFiveDigits_WhenProcessInput_ThenSpaceIsAdded() {
        // Given
        let userInput = "1 0000 $"
        
        // When
        let currencyIOValues = sut.processInput(
            input: userInput,
            for: .usdToEuro
        )
        
        // Then
        XCTAssertEqual(
            currencyIOValues.input, "10 000 $"
        )
    }
    
    func testGivenUserInputHasSixDigits_WhenProcessInput_ThenSpaceIsAdded() {
        // Given
        let userInput = "10 0000 $"
        
        // When
        let currencyIOValues = sut.processInput(
            input: userInput,
            for: .usdToEuro
        )
        
        // Then
        XCTAssertEqual(
            currencyIOValues.input, "100 000 $"
        )
    }

    // MARK: - Pasteboard tests
    
    func testGivenCopiedValue_WhenCopyInPasteboard_ThenCopiedValueIsSetInPasteboard() {
        // Given
        let copiedValue = "2,000 $"

        // When
        sut.copy(value: copiedValue)

        // Then
        XCTAssertEqual(
            pasteboardService.fetchValue(),
            "2,000"
        )
    }
    
    func testGivenPastedValue_WhenPasteInInput_ThenCopiedValueIsSetInPasteboard() {
        // Given
        userDefaults.set(20211002, forKey: currencyDateUDKey)
        currentDate = .mockDate20211002
        
        userDefaults.set(2.0, forKey: euroToUSDRateUDKey)
        
        sut.copy(value: "2,000 $")

        // When
        let _ = sut.pasteInInput(of: .usdToEuro)

        // Then
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
        
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            
            XCTAssertEqual(
                self.usdToEuroIOValues,
                CurrencyIOValues(
                    input: "2 $",
                    output: ["1,000 €"]
                )
            )
        }
    }
    
    func testGivenEmptyPasteboard_WhenPasteInInput_ThenCopiedValueIsSetInPasteboard() {
        // Given
        usdToEuroIOValues = CurrencyIOValues(
            input: "2 $",
            output: ["1,500 €"]
        )
        
        let currencyRateHTTPData = CurrencyRateHTTPData(
            success: true,
            date: "2021-10-03",
            rates: CurrencyRateHTTPData.Rates(USD: 2.0)
        )
        currencyService.bpnError = nil
        currencyService.currencyRateHTTPData = currencyRateHTTPData
        
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
        
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            // When
            let currencyValue = self.sut.pasteInInput(of: .usdToEuro)

            // Then
            XCTAssertEqual(
                currencyValue,
                nil
            )
        }
    }
    
    
    
    // MARK: - Useless commas test
    
    func testWhenUselessCommasInInput_WhenGivenRemoveUselessCommasFromInputs_ThenInputValuesAreSanitized() {
        // Given
        userDefaults.set("0, $", forKey: usdToEuroInputUDKey)
        
        userDefaults.set("0, $", forKey: usdToEuroInputUDKey)
        userDefaults.set("0, €", forKey: euroToUSDInputUDKey)
        userDefaults.set("0, $", forKey: vatInputUDKey)
        userDefaults.set("0, $", forKey: tipInputUDKey)
        
        sut.removeUselessCommasFromInputs()
        
        // When
        XCTAssertEqual(
            self.usdToEuroIOValues,
            CurrencyIOValues(
                input: "0 $",
                output: ["0 €"]
            )
        )
        XCTAssertEqual(
            self.euroToUSDIOValues,
            CurrencyIOValues(
                input: "0 €",
                output: ["0 $"]
            )
        )
        XCTAssertEqual(
            self.vatIOValues,
            CurrencyIOValues(
                input: "0 $",
                output: ["0 $"]
            )
        )
        XCTAssertEqual(
            self.tipIOValues,
            CurrencyIOValues(
                input: "0 $",
                output: ["0 $", "0 $"]
            )
        )
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
