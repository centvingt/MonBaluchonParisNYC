//
//  MockUserDefaults.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 18/06/2021.
//

@testable import MonBaluchonParisNYC

class MockUserDefaults: BPNUserDefaultsProtocol {
    var store: [String:Any?] = [:]
    
    func set(_ value: Any?, forKey defaultName: String) {
        switch defaultName {
        case "euroToUSDRate":
            if let value = value as? Double {
                store[defaultName] = value
            }
        case "currencyDate",
             "translationRequestTimestampCounter",
             "translationRequestCounter":
            if let value = value as? Int {
                store[defaultName] = value
            }
        case "usdToEuroInput",
             "euroToUSDInput",
             "vatInput",
             "tipInput":
            if let value = value as? String {
                store[defaultName] = value
            }
        default:
            return
        }
    }
    
    func integer(forKey defaultName: String) -> Int {
        guard let value = store[defaultName] as? Int else { return 0 }
        return value
    }
    
    func string(forKey defaultName: String) -> String? {
        return store[defaultName] as? String
    }
    
    func double(forKey defaultName: String) -> Double {
        guard let double = store[defaultName] as? Double else { return 0 }
        return double
    }
}
