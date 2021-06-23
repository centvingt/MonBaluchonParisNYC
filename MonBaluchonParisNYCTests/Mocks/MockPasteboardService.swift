//
//  MockPasteboardService.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 22/06/2021.
//

@testable import MonBaluchonParisNYC
import Foundation

class MockPasteboardService: PasteboardServiceProtocol {
    private var value: String?
    
    func set(value: String) {
        self.value = value
    }
    
    func fetchValue() -> String? {
        guard let value = value else { return nil }
        return value
    }
}
