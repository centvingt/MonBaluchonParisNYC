//
//  CoreDataStorageTestCase.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 08/07/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class CoreDataStorageTestCase: XCTestCase {
    var sut = CoreDataStorage(.inMemory)
    
    var weatherHTTPData = WeatherHTTPData(
        weather: [
            WeatherHTTPData.Weather(
                description: "nuageux",
                icon: "04d"
            )
        ],
        main: WeatherHTTPData.Main(
            temp: 23.78,
            temp_min: 19.97,
            temp_max: 26.93
        ),
        dt: 1625415627,
        sys: WeatherHTTPData.Sys(
            sunrise: 1625391011,
            sunset: 1625445026
        ),
        id: 5128581,
        timezone: -14400
    )
    var secondWeatherHTTPData = WeatherHTTPData(
        weather: [
            WeatherHTTPData.Weather(
                description: "nuageux 2",
                icon: "04d 2"
            )
        ],
        main: WeatherHTTPData.Main(
            temp: 25.78,
            temp_min: 21.97,
            temp_max: 28.93
        ),
        dt: 1625415629,
        sys: WeatherHTTPData.Sys(
            sunrise: 1625391013,
            sunset: 1625445028
        ),
        id: 5128581,
        timezone: -14402
    )

    var expectedValueOfWeatherDescription: String? = "nuageux"
    var expectedValueOfDateTime: Int64 = 1625415627
    var expectedValueOfIconName: String? = "04d"
    var expectedValueOfTemp: Float = 23.78
    var expectedValueOfTempMin: Float = 19.97
    var expectedValueOfTempMax: Float = 26.93
    var expectedValueOfSunrise: Int64 = 1625391011
    var expectedValueOfSunset: Int64 = 1625445026
    
    override func setUp() {
        super.setUp()
        
        sut = CoreDataStorage(.inMemory)
    }
    
    func testGivenCityDataStored_WhenGetCityData_ThenReturnCorrectData() {
        // Given
        sut.saveWeather(weatherHTTPData)
        
        // When
        let query = sut.getWeatherOfCity(id: City.nyc.getCityWeatherID())
        
        // Then
        XCTAssertEqual(
            query?.weather[0].description,
            expectedValueOfWeatherDescription
        )
        XCTAssertEqual(
            query?.dt,
            expectedValueOfDateTime
        )
        XCTAssertEqual(
            query?.weather[0].icon,
            expectedValueOfIconName
        )
        XCTAssertEqual(
            query?.main.temp,
            expectedValueOfTemp
        )
        XCTAssertEqual(
            query?.main.temp_min,
            expectedValueOfTempMin
        )
        XCTAssertEqual(
            query?.main.temp_max,
            expectedValueOfTempMax
        )
        XCTAssertEqual(
            query?.sys.sunrise,
            expectedValueOfSunrise
        )
        XCTAssertEqual(
            query?.sys.sunset,
            expectedValueOfSunset
        )
    }
    
    func testGivenDataOfCorrectCityNotStored_WhenGetCityData_ThenReturnError() {
        // Given
        sut.saveWeather(weatherHTTPData)

        // When
        let query = sut.getWeatherOfCity(id: City.paris.getCityWeatherID())
        
        // Then
        XCTAssertNil(query)
    }
    
    func testGivenCityDataStored_WhenSaveNewDataOfSameCity_ThenGetWeatherReturnCorrectData() {
        // Given
        sut.saveWeather(weatherHTTPData)
        
        // When
        sut.saveWeather(secondWeatherHTTPData)
        
        // Then
        let query = sut.getWeatherOfCity(id: City.nyc.getCityWeatherID())

        XCTAssertEqual(
            query?.weather[0].description,
            "nuageux 2"
        )
        XCTAssertEqual(
            query?.dt,
            1625415629
        )
        XCTAssertEqual(
            query?.weather[0].icon,
            "04d 2"
        )
        XCTAssertEqual(
            query?.main.temp,
            25.78
        )
        XCTAssertEqual(
            query?.main.temp_min,
            21.97
        )
        XCTAssertEqual(
            query?.main.temp_max,
            28.93
        )
        XCTAssertEqual(
            query?.sys.sunrise,
            1625391013
        )
        XCTAssertEqual(
            query?.sys.sunset,
            1625445028
        )
    }
}
