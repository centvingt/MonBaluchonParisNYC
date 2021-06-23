//
//  CityTestCase.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 23/06/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class CityTestCase: XCTestCase {
    func testGivenRequestHasAUnknowdError_WhenGetRate_ThenUndefinedErrorIsThrown() {
        // Given
        let paris = City.paris
        let nyc = City.nyc
        
        // When
        let parisCurrency = paris.getCurrency()
        let nycCurrency = nyc.getCurrency()
        
        // Then
        XCTAssertEqual(parisCurrency.name, "euro")
        XCTAssertEqual(parisCurrency.convertSymbol, "$")
        
        XCTAssertEqual(nycCurrency.name, "dollar")
        XCTAssertEqual(nycCurrency.convertSymbol, "€")
    }
}
