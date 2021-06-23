//
//  PasteboardServiceTestCase.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 23/06/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class PasteboardServiceTestCase: XCTestCase {
    let sut = PasteboardService()
    
    override func setUp() {
        UIPasteboard.general.items = []
    }
    
    func testGivenStringInput_WhenSetPasteboard_ThenResponseIsStringInput() {
        // Given
        let input = "abcd"
        
        // When
        sut.set(value: input)
        
        // Then
        let output = sut.fetchValue()
        
        XCTAssertEqual(output!, input)
    }
    
    func testGivenImage_WhenSetString_ThenResponseIsASuccess() {
        // Given
        let input = UIImage()
        
        // When
        UIPasteboard.general.image = input
        
        // Then
        let output = sut.fetchValue()
        
        XCTAssertEqual(output, nil)
    }
}
