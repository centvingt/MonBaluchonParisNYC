//
//  MockTranslationService.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 03/07/2021.
//

import Foundation
@testable import MonBaluchonParisNYC

class MockTranslationService: TranslationServiceProtocol {
    var bpnError: BPNError?
    var response: String?
    
    func getTranslation(
        of text: String,
        from: TranslationLanguage,
        to: TranslationLanguage,
        completion: @escaping (BPNError?, String?) -> ()
    ) {
        completion(bpnError, response)
    }
}
