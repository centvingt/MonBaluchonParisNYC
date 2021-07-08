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
    
    func testGivenCity_WhenGetLanguage_ThenReturnCorrectValues() {
        // Given
        let paris = City.paris
        let nyc = City.nyc
        
        // When
        let parisLanguage = paris.language
        let nycLanguage = nyc.language
        
        // Then
        XCTAssertEqual(parisLanguage.from, .fr)
        XCTAssertEqual(parisLanguage.to, .en)
        
        XCTAssertEqual(nycLanguage.from, .en)
        XCTAssertEqual(nycLanguage.to, .fr)
    }
    
    func testGivenCity_WhenGetWeatherID_ThenReturnCorrectValue() {
        // Given
        let paris = City.paris
        let nyc = City.nyc
        
        // When
        let parisID = paris.getCityWeatherID()
        let nycID = nyc.getCityWeatherID()
        
        // Then
        XCTAssertEqual(parisID, 2988507)
        XCTAssertEqual(nycID, 5128581)
    }
}
