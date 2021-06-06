//
//  Currency.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

class Currency {
    private var euroToUSDRate: Float?
    private var usdToEuroRate: Float? {
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
    private var tip15Input: String {
        guard let value = userDefaults.string(
            forKey: getUserDefaults(for: .tip15)
        ) else {
            return "0" + getInputSuffix(for: .tip15)
        }
        return value
    }
    private var tip20Input: String {
        guard let value = userDefaults.string(
            forKey: getUserDefaults(for: .tip20)
        ) else {
            return "0" + getInputSuffix(for: .tip20)
        }
        return value
    }
    
    private let userDefaults = UserDefaults.standard
    private let rateUserDefaultsKey = "rate"
    private let dateUsersDefaultsKey = "currencyDate"
    private let usdToEuroInputDefaultsKey = "usdToEuroInput"
    private let euroToUSDInputDefaultsKey = "euroToUSDInput"
    private let vatInputDefaultsKey = "vatInput"
    private let tip15InputDefaultsKey = "tip15Input"
    private let tip20InputDefaultsKey = "tip20Input"
    
    private func getIntDateFromString(_ stringDate: String) -> Int? {
        let sanitizedStringDate = stringDate.filter { $0 != "-"}
        
        guard let intDate = Int(sanitizedStringDate) else {
            return nil
        }
        return intDate
    }
    
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
            euroToUSDRate = userDefaults.float(forKey: rateUserDefaultsKey)
            date = userDefaults.integer(forKey: dateUsersDefaultsKey)
            
            postDataNotification()
        }
    }
    private func postDataNotification() {
        guard let euroToUSDRateFloat = self.euroToUSDRate,
              let usdToEuroRateFloat = self.usdToEuroRate,
              let rateDate = self.formatedDate,
              let euroToUSDRate = getStringFromDouble(Double(euroToUSDRateFloat)),
              let usdToEuroRate = getStringFromDouble(Double(usdToEuroRateFloat))
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
                "rateDate": rateDate
            ]
        )
    }
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
    
    func processInput(input: String, for calculation: CurrencyCalculation) -> String {
        let inputContainsPoint = input.contains(".")
        let lastCharacter = input.suffix(3).first
        let lastCharacterIsComma = lastCharacter == "," || lastCharacter == "."
        
        guard let inputConvertedToDouble = getDoubleFromInput(
            input,
            for: calculation
        ) else {
            return getValue(for: calculation)
        }

        let inputIsRounded = floor(inputConvertedToDouble) == inputConvertedToDouble
        
        guard let newInputFromFloat = getStringFromDouble(
            inputConvertedToDouble,
            minimumFractionDigits: inputContainsPoint ? 1 : 0
        ) else {
            return getValue(for: calculation)
        }

        var newInput = newInputFromFloat
        
        if inputIsRounded
            && lastCharacterIsComma
        {
            if newInput.last == "0" { newInput.removeLast() }
            else { newInput += "," }
        }
        newInput += getInputSuffix(for: calculation)
        
        userDefaults.set(
            newInput,
            forKey: getUserDefaults(for: calculation)
        )
        return newInput
    }
    
    private func getDoubleFromInput(
        _ input: String,
        for calculation: CurrencyCalculation
    ) -> Double? {
        var sanitizedInput = input
            .replacingOccurrences(
                of: getInputSuffix(for: calculation),
                with: ""
            )
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        if let index = sanitizedInput.firstIndex(of: "."),
           sanitizedInput[index...].count == 5 {
            sanitizedInput.removeLast()
        }
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
        case .usdToEuro, .vat, .tip15, .tip20:
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
        case .tip15:
            return tip15InputDefaultsKey
        case .tip20:
            return tip20InputDefaultsKey
        }
    }
    private func getValue(for calculation: CurrencyCalculation) -> String {
        switch calculation {
        case .usdToEuro:
            return usdToEuroInput
        case .euroToUSD:
            return euroToUSDInput
        case .vat:
            return vatInput
        case .tip15:
            return tip15Input
        case .tip20:
            return tip20Input
        }
    }
}
