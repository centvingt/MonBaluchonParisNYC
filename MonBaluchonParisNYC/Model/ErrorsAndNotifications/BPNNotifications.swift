//
//  BPNNotifications.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 24/05/2021.
//

import Foundation

extension Notification.Name {
    static let errorInternetConnection = Notification.Name("errorInternetConnection")
    static let errorUndefined = Notification.Name("errorUndefined")
    static let errorBadPasteboardValue = Notification.Name("errorBadPasteboardValue")
    static let currencyRateData = Notification.Name("currencyRateData")
    static let weatherData = Notification.Name("weatherData")
}
