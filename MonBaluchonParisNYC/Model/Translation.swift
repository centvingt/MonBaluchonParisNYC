//
//  Translation.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 27/06/2021.
//

import Foundation

struct Translation {
    private let translationService = TranslationService.shared
    
    func getTranslation(
        of text: String,
        from: TranslationLanguage,
        to: TranslationLanguage,
        completion: @escaping (BPNError?, String?) -> ()
    ) {
        translationService.getTranslation(
            of: "traduction",
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
