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
    
    private let userDefaults = UserDefaults.standard
    private let rateUserDefaultsKey = "euroToUSDRate"
    private let dateUsersDefaultsKey = "currencyDate"
    
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
              let euroToUSDRate = formatRateNumber(euroToUSDRateFloat),
              let usdToEuroRate = formatRateNumber(usdToEuroRateFloat)
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
    private func formatRateNumber(_ float: Float) -> String? {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3

        return formatter.string(for: float)
    }
    
//    func convertDollarToEuro(dollar: String) -> String? {
//        dollar
//    }
}
