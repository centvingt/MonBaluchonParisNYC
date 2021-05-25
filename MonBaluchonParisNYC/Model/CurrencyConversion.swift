//
//  CurrencyConversion.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

class CurrencyConversion {
    private var euroToUSDRate: Float?
    private var usdToEuroRate: Float? {
        guard let euroUSDRate = euroToUSDRate else { return nil }
        return 1 / euroUSDRate
    }
    private var date: Int? {
        didSet {
            
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let rateUserDefaultsKey = "euroToUSDRate"
    private let dateUsersDefaultKey = "euroToUSDRateDate"
    
    private func getIntDateFromString(_ stringDate: String) -> Int? {
        let sanitizedStringDate = stringDate.filter { $0 != "-"}
        
        guard let intDate = Int(sanitizedStringDate) else {
            return nil
        }
        return intDate
    }
    
    func setRate() {
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
        
        let userDefaultsDate = userDefaults.integer(forKey: dateUsersDefaultKey)
        
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
                
                self.userDefaults.set(self.euroToUSDRate, forKey: self.rateUserDefaultsKey)
                self.euroToUSDRate = data.rates.USD
                
                self.userDefaults.set(self.date, forKey: self.dateUsersDefaultKey)
                self.date = intDate
                
                print("New fixer.io request")
                self.postDataNotification()
            }
        } else {
            euroToUSDRate = userDefaults.float(forKey: rateUserDefaultsKey)
            date = userDefaults.integer(forKey: dateUsersDefaultKey)
            
            postDataNotification()
        }
    }
    private func postDataNotification() {
        guard let euroToUSDRate = self.euroToUSDRate,
              let usdToEuroRate = self.usdToEuroRate,
              let date = self.date else {
            print("CurrencyConversion ~> postDataNotification ~> nil data")
            NotificationCenter.default.post(Notification(name: .errorUndefined))
            return
        }
        print("CurrencyConversion ~> postDataNotification ~> euroToUSDRate", euroToUSDRate)
        print("CurrencyConversion ~> postDataNotification ~> usdToEuroRate", usdToEuroRate)
        print("CurrencyConversion ~> postDataNotification ~> date", date)
        NotificationCenter.default.post(
            name: .currencyRateData,
            object: self,
            userInfo: [
                "euroToUSDRate": euroToUSDRate,
                "usdToEuroRate": usdToEuroRate,
                "date": date
            ]
        )
    }
}
