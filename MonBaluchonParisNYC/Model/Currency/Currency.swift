//
//  Currency.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

class Currency {
    // MARK: - Data
    
    private var euroToUSDRate: Double?
    private var usdToEuroRate: Double? {
        guard let euroUSDRate = euroToUSDRate else { return nil }
        return 1 / euroUSDRate
    }
    private var date: Int?
    private var formatedDate: String? {
        guard let date = date else { return nil }
        
        let firstFormatter = DateFormatter()
        firstFormatter.dateFormat = "yyyyMMdd"
        guard let firstDate = firstFormatter.date(
            from: String(date)
        ) else { return nil }
        
        let secondFormatter = DateFormatter()
        secondFormatter.locale = Locale(identifier: "fr-FR")
        secondFormatter.dateFormat = "eeee d MMMM yyyy"
        return secondFormatter.string(from: firstDate)
    }
    private var inputConversion: Float?
    private let vatRate = 1.08875
    
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
    
    private let userDefaults = UserDefaults.standard
    private let rateUserDefaultsKey = "rate"
    private let dateUsersDefaultsKey = "currencyDate"
    private let usdToEuroInputDefaultsKey = "usdToEuroInput"
    private let euroToUSDInputDefaultsKey = "euroToUSDInput"
    private let vatInputDefaultsKey = "vatInput"
    private let tipInputDefaultsKey = "tipInput"
    
    // MARK: - Getting data from api
    
    func getRate() {
        let nowFormat = DateFormatter()
        nowFormat.dateFormat = "yyyy-MM-dd"
        nowFormat.timeZone = TimeZone(abbreviation: "CET")
        let nowStringDate = nowFormat.string(from: Date())
        
        guard let nowIntDate = getIntDateFromString(nowStringDate)
        else {
            print("Convert nowStringDate to Int error")
            NotificationCenter.default.post(Notification(name: .errorUndefined))
            return
        }
        
        let userDefaultsDate = userDefaults.integer(forKey: dateUsersDefaultsKey)
        
        if userDefaultsDate == 0 || nowIntDate > userDefaultsDate {
            CurrencyService.shared.getRate { error, data in
                if let error = error {
                    print("ERREUR!!!", error)
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
                    print("data or data.date is equal to nil")
                    NotificationCenter.default.post(Notification(name: .errorUndefined))
                    return
                }
                
                self.euroToUSDRate = data.rates.USD
                self.userDefaults.set(self.euroToUSDRate, forKey: self.rateUserDefaultsKey)
                
                self.date = intDate
                self.userDefaults.set(self.date, forKey: self.dateUsersDefaultsKey)
                
                print("Currency ~> getRate ~> NEW CURRENCY REQUEST")
                self.postDataNotification()
            }
        } else {
            euroToUSDRate = userDefaults.double(forKey: rateUserDefaultsKey)
            date = userDefaults.integer(forKey: dateUsersDefaultsKey)
            
            postDataNotification()
        }
    }
    
    // MARK: - Post notifications
    
    private func postDataNotification() {
        guard let euroToUSDRateFloat = self.euroToUSDRate,
              let usdToEuroRateFloat = self.usdToEuroRate,
              let rateDate = self.formatedDate,
              let euroToUSDRate = getStringFromDouble(euroToUSDRateFloat),
              let usdToEuroRate = getStringFromDouble(usdToEuroRateFloat)
        else {
            print("Currency ~> postDataNotification ~> nil data")
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
        var newInput = input.replacingOccurrences(of: ".", with: ",")
        
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
            print("condition")
            let removeIndex = newInput.index(before: endIndex)
            newInput.remove(at: removeIndex)
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
        /* Remove " $" or " €" from value
         before set this value in pasteboard */
        PasteboardService.set(
            value: String(value.dropLast(2))
        )
    }
    func pasteInInput(
        of calculation: CurrencyCalculation
    ) -> CurrencyIOValues? {
        guard let string = PasteboardService.fetchValue(),
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
    
    private func getIntDateFromString(_ stringDate: String) -> Int? {
        let sanitizedStringDate = stringDate.filter { $0 != "-"}
        
        guard let intDate = Int(sanitizedStringDate) else {
            return nil
        }
        return intDate
    }
    
    // MARK: - IO helperes
    
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
              double < 1_000_000 else {
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
            return usdToEuroInputDefaultsKey
        case .euroToUSD:
            return euroToUSDInputDefaultsKey
        case .vat:
            return vatInputDefaultsKey
        case .tip:
            return tipInputDefaultsKey
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
