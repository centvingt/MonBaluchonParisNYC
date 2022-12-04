//
//  Translation.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 27/06/2021.
//

import Foundation

class Translation {
    // MARK: - Dependency injection
    
    private let translationService: TranslationServiceProtocol
    private let userDefaults: BPNUserDefaultsProtocol
    
    init(
        userDefaults: BPNUserDefaultsProtocol = UserDefaults.standard,
        translationService: TranslationServiceProtocol = TranslationService.shared
    ) {
        self.userDefaults = userDefaults
        self.translationService = translationService
    }
    
    let maxCharacters = 100
    let maxRequestPerDay = 20
    
    private var requestTimestampCounter: Int {
        get {
            let timestamp = userDefaults
                .integer(forKey: requestTimestampCounterUDKey)
            guard timestamp != 0 else {
                let timestamp = Int(currentDate.value().timeIntervalSince1970)
                return timestamp
            }
            return timestamp
        }
        set {
            userDefaults.set(newValue, forKey: requestTimestampCounterUDKey)
        }
    }
    private var requestCounter: Int {
        get {
            return userDefaults
                .integer(forKey: requestCounterUDKey)
        }
        set {
            userDefaults.set(newValue, forKey: requestCounterUDKey)
        }
    }
    private var newRequestIsAllowed: Bool {
        let currentDate = Int(currentDate.value().timeIntervalSince1970)

        if currentDate == requestTimestampCounter {
            return requestCounter <= maxRequestPerDay
        }
        
        if currentDate > requestTimestampCounter {
            requestCounter = 0
            return true
        }
        
        return false
    }
    
    // MARK: - User Defaults Keys
    
    private let requestTimestampCounterUDKey = "translationRequestTimestampCounter"
    private let requestCounterUDKey = "translationRequestCounter"
    
    // MARK: - Service request
    
    func getTranslation(
        of text: String,
        from: TranslationLanguage,
        to: TranslationLanguage,
        completion: @escaping (BPNError?, String?) -> ()
    ) {
        requestCounter += 1
        
        guard newRequestIsAllowed else {
            completion(BPNError.translationRequestLimitExceeded, nil)
            return
        }
        
        requestTimestampCounter = Int(currentDate.value().timeIntervalSince1970)
        
        translationService.getTranslation(
            of: text,
            from: from,
            to: to
        ) { error, string in
            if let error = error {
                if error == .internetConnection {
                    completion(.internetConnection, nil)
                } else {
                    completion(.undefinedRequestError, nil)
                }
                return
            }
            
            guard let string = string else {
                completion(.undefinedRequestError, nil)
                return
            }
            
            completion(nil, string)
        }
    }
}
