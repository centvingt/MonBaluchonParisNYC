//
//  Currency.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

class Currency {
    // MARK: - Dependency injection
    
    private let userDefaults: BPNUserDefaultsProtocol
    private let currencyService: CurrencyServiceProtocol
    private let pasteboardService: PasteboardServiceProtocol
    
    init(
        userDefaults: BPNUserDefaultsProtocol = UserDefaults.standard,
        currencyService: CurrencyServiceProtocol = CurrencyService.shared,
        pasteboardService: PasteboardServiceProtocol = PasteboardService()
    ) {
        self.userDefaults = userDefaults
        self.currencyService = currencyService
        self.pasteboardService = pasteboardService
    }
    
    // MARK: - Data
    
    private var euroToUSDRate: Double?
    private var usdToEuroRate: Double? {
        guard let euroUSDRate = euroToUSDRate else { return nil }
        return 1 / euroUSDRate
    }
    private var date: Int?
    private var formatedDate: String? {
        let firstFormatter = DateFormatter()
        firstFormatter.dateFormat = "yyyyMMdd"
        
        guard let date = date,
              date > 0,
              let firstDate = firstFormatter.date(
                from: String(date)
              )
        else { return nil }
        
        let secondFormatter = DateFormatter()
        secondFormatter.locale = Locale(identifier: "fr-FR")
        secondFormatter.dateFormat = "eeee d MMMM yyyy"
        return secondFormatter.string(from: firstDate)
    }
    private var inputConversion: Float?
    private let vatRate = 1.08875
    private let maxValue: Double = 1_000_000
    
    // MARK: - Input values
    
    private var usdToEuroInput: String {
        guard let value = userDefaults.string(
            forKey: getUserDefaults(for: .usdToEuro)
        ) else {
            return "0" + getInputSuffix(for: .usdToEuro)
        }
        return value
    }
    private var euroToUSDInput: String {
        guard let value = userDefaults.string(
            forKey: getUserDefaults(for: .euroToUSD)
        ) else {
            return "0" + getInputSuffix(for: .euroToUSD)
        }
        return value
    }
    private var vatInput: String {
        guard let value = userDefaults.string(
            forKey: getUserDefaults(for: .vat)
        ) else {
            return "0" + getInputSuffix(for: .vat)
        }
        return value
    }
    private var tipInput: String {
        guard let value = userDefaults.string(
            forKey: getUserDefaults(for: .tip)
        ) else {
            return "0" + getInputSuffix(for: .tip)
        }
        return value
    }
    private var usdToEuroOutput: String {
        let suffix = " €"
        guard
            let double = getDoubleFromInput(
                usdToEuroInput,
                for: .usdToEuro
            ),
            let usdToEuroRate = usdToEuroRate,
            let result = getStringFromDouble(double * usdToEuroRate)
        else { return "0" + suffix }
        return result + suffix
    }
    private var euroToUSDOutput: String {
        let suffix = " $"
        guard
            let double = getDoubleFromInput(
                euroToUSDInput,
                for: .euroToUSD
            ),
            let euroToUSDRate = euroToUSDRate,
            let result = getStringFromDouble(double * euroToUSDRate)
        else { return "0" + suffix }
        return result + suffix
    }
    private var vatOutput: String {
        let suffix = " $"
        guard
            let double = getDoubleFromInput(
                vatInput,
                for: .vat
            ),
            let result = getStringFromDouble(double * vatRate)
        else { return "0" + suffix }
        return result + suffix
    }
    private var tip15Output: String {
        let suffix = " $"
        guard
            let double = getDoubleFromInput(
                tipInput,
                for: .tip
            ),
            let result = getStringFromDouble(double * 1.15)
        else { return "0" + suffix }
        return result + suffix
    }
    private var tip20Output: String {
        let suffix = " $"
        guard
            let double = getDoubleFromInput(
                tipInput,
                for: .tip
            ),
            let result = getStringFromDouble(double * 1.20)
        else { return "0" + suffix }
        return result + suffix
    }
    
    // MARK: - User Defaults Keys
    
    private let euroToUSDRateUDKey = "euroToUSDRate"
    private let currencyDateUDKey = "currencyDate"
    private let usdToEuroInputUDKey = "usdToEuroInput"
    private let euroToUSDInputUDKey = "euroToUSDInput"
    private let vatInputUDKey = "vatInput"
    private let tipInputUDKey = "tipInput"
    
    // MARK: - Getting data from api
    
    func getRate() {
        let currentIntDate = getCurrentIntDate()
        let userDefaultsDate = userDefaults.integer(forKey: currencyDateUDKey)
        
        if userDefaultsDate == 0 || currentIntDate > userDefaultsDate {
            currencyService.getRate { error, data in
                if let error = error {
                    var notification: Notification
                    if error == .internetConnection {
                        notification = Notification(name: .errorInternetConnection)
                    } else {
                        notification = Notification(name: .errorUndefined)
                    }
                    NotificationCenter.default.post(notification)
                    return
                }
                
                guard let data = data,
                      let intDate = self.getIntDateFromString(data.date) else {
                    NotificationCenter.default.post(Notification(name: .errorUndefined))
                    return
                }
                
                self.euroToUSDRate = data.rates.USD
                self.userDefaults.set(
                    self.euroToUSDRate,
                    forKey: self.euroToUSDRateUDKey
                )
                
                self.date = intDate
                self.userDefaults.set(
                    self.date,
                    forKey: self.currencyDateUDKey
                )
                
                print("Currency ~> getRate ~> NEW CURRENCY REQUEST")
                self.postDataNotification()
            }
        } else {
            euroToUSDRate = userDefaults.double(forKey: euroToUSDRateUDKey)
            date = userDefaults.integer(forKey: currencyDateUDKey)
            
            postDataNotification()
        }
    }
    
    // MARK: - Post notifications
    
    private func postDataNotification() {
        guard let euroToUSDRateDouble = self.euroToUSDRate,
              let usdToEuroRateDouble = self.usdToEuroRate,
              euroToUSDRateDouble != 0,
              usdToEuroRateDouble != 0,
              let rateDate = self.formatedDate,
              let euroToUSDRate = getStringFromDouble(euroToUSDRateDouble),
              let usdToEuroRate = getStringFromDouble(usdToEuroRateDouble)
        else {
            NotificationCenter.default.post(Notification(name: .errorUndefined))
            return
        }
        
        NotificationCenter.default.post(
            name: .currencyRateData,
            object: self,
            userInfo: [
                "euroToUSDRate": euroToUSDRate,
                "usdToEuroRate": usdToEuroRate,
                "rateDate": rateDate,
                "usdToEuroIOValues": getIOValues(for: .usdToEuro),
                "euroToUSDIOValues": getIOValues(for: .euroToUSD),
                "vatIOValues": getIOValues(for: .vat),
                "tipIOValues": getIOValues(for: .tip)
            ]
        )
    }
    
    // MARK: - IO handling
    
    func processInput(
        input: String,
        for calculation: CurrencyCalculation
    ) -> CurrencyIOValues {
        guard let doubleFromInput = getDoubleFromInput(input, for: calculation) else {
            return getIOValues(for: calculation)
        }
        
        var newInput = input
            .replacingOccurrences(of: ".", with: ",")
        
        if newInput.prefix(1) == "0"
            && newInput.prefix(2) != "0," {
            newInput.removeFirst()
        }
        
        if newInput.count == 2 { newInput = "0" + newInput }
        
        let endIndex = newInput.index(
            newInput.endIndex,
            offsetBy: -2
        )
        if let commaIndex = newInput.firstIndex(of: ","),
           newInput[commaIndex..<endIndex].count == 5 {
            let removeIndex = newInput.index(before: endIndex)
            newInput.remove(at: removeIndex)
        }
        
        if doubleFromInput >= 1_000 {
            let suffix = getInputSuffix(for: calculation)
            newInput = newInput.replacingOccurrences(of: suffix, with: "")
                .replacingOccurrences(of: " ", with: "")
            
            if 1_000..<10_000 ~= doubleFromInput {
                let index = newInput.index(newInput.startIndex, offsetBy: 1)
                newInput.insert(" ", at: index)
            }
            if 10_000..<100_000 ~= doubleFromInput {
                let index = newInput.index(newInput.startIndex, offsetBy: 2)
                newInput.insert(" ", at: index)
            }
            if 100_000..<1_000_000 ~= doubleFromInput {
                let index = newInput.index(newInput.startIndex, offsetBy: 3)
                newInput.insert(" ", at: index)
            }
            
            newInput.append(suffix)
        }
        
        userDefaults.set(
            newInput,
            forKey: getUserDefaults(for: calculation)
        )
        
        return getIOValues(for: calculation)
    }
    func deleteInput(for calculation: CurrencyCalculation) -> CurrencyIOValues {
        let newIOValues = CurrencyIOValues(for: calculation)
        
        userDefaults.set(
            newIOValues.input,
            forKey: getUserDefaults(for: calculation)
        )
        
        return newIOValues
    }
    func copy(
        value: String
    ) {
        /* value.dropLast removes " $" or " €" from value
         before set this value in pasteboard */
        pasteboardService.set(
            value: String(value.dropLast(2))
        )
    }
    func pasteInInput(
        of calculation: CurrencyCalculation
    ) -> CurrencyIOValues? {
        guard let string = pasteboardService.fetchValue(),
              let double = getDoubleFromInput(
                string,
                for: calculation
              ),
              let formattedString = getStringFromDouble(double, minimumFractionDigits: 0)
        else {
            return nil
        }
        
        return processInput(
            input: formattedString
                + getInputSuffix(for: calculation),
            for: calculation
        )
    }
    
    // MARK: - Helpers
    
    // MARK: Date helper
    
    private func getCurrentIntDate() -> Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "CET") ?? calendar.timeZone
        
        let currentDate = currentDate.value()
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        
        let dateComponents = [ year, month, day ]
        
        var intDate = 0
        let indexes = 0...2
        indexes.forEach { index in
            let dateComponent = dateComponents[index]
            
            if index == 0 {
                intDate = dateComponent
            } else {
                intDate = intDate * 100 + dateComponent
            }
        }
        return intDate
    }
    
    private func getIntDateFromString(_ stringDate: String) -> Int? {
        let sanitizedStringDate = stringDate.filter { $0 != "-"}
        
        guard let intDate = Int(sanitizedStringDate) else {
            return nil
        }
        return intDate
    }
    
    // MARK: IO helperes
    
    private func getStringFromDouble(
        _ double: Double,
        minimumFractionDigits: Int = 3
    ) -> String? {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        
        return formatter.string(for: double)
    }
    private func getDoubleFromInput(
        _ input: String,
        for calculation: CurrencyCalculation
    ) -> Double? {
        let sanitizedInput = input
            .replacingOccurrences(
                of: getInputSuffix(for: calculation),
                with: ""
            )
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        
        guard !sanitizedInput.isEmpty else {
            return 0
        }
        guard let double = Double(sanitizedInput),
              double < maxValue else {
            return nil
        }
        
        return double
    }
    
    private func getInputSuffix(for calculation: CurrencyCalculation) -> String {
        switch calculation {
        case .euroToUSD:
            return " €"
        case .usdToEuro, .vat, .tip:
            return " $"
        }
    }
    private func getUserDefaults(
        for calculation: CurrencyCalculation
    ) -> String {
        switch calculation {
        case .usdToEuro:
            return usdToEuroInputUDKey
        case .euroToUSD:
            return euroToUSDInputUDKey
        case .vat:
            return vatInputUDKey
        case .tip:
            return tipInputUDKey
        }
    }
    private func getIOValues(
        for calculation: CurrencyCalculation
    ) -> CurrencyIOValues {
        switch calculation {
        case .usdToEuro:
            return CurrencyIOValues(
                input: usdToEuroInput,
                output: [usdToEuroOutput]
            )
        case .euroToUSD:
            return CurrencyIOValues(
                input: euroToUSDInput,
                output: [euroToUSDOutput]
            )
        case .vat:
            return CurrencyIOValues(
                input: vatInput,
                output: [vatOutput]
            )
        case .tip:
            return CurrencyIOValues(
                input: tipInput,
                output: [tip15Output, tip20Output]
            )
        }
    }
    func removeUselessCommasFromInputs() {
        var valuesHaveChanged = false
        
        CurrencyCalculation.allCases.forEach { calculation in
            let inputValue = getIOValues(for: calculation).input
            if inputValue.suffix(3)[0] == "," {
                userDefaults.set(
                    inputValue.replacingOccurrences(of: ",", with: ""),
                    forKey: getUserDefaults(for: calculation)
                )
                valuesHaveChanged = true
            }
        }
        
        if valuesHaveChanged { postDataNotification() }
    }
}
