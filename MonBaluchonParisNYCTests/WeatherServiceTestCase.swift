//
//  WeatherServiceTestCase.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 08/07/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class WeatherServiceTestCase: XCTestCase {
    var weatherService: WeatherService!
    var expectation: XCTestExpectation!
    let timeOut = 1.0
    
    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession.init(configuration: configuration)
        
        weatherService = WeatherService(
            session: session,
            apiURL: MockResponseData.goodURL
        )
        expectation = expectation(description: "Weather expectation")
    }
    
    func testGivenResponseAndDataAreCorrect_WhenGetWeather_ThenResponseIsASuccess() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseOK,
                data: MockResponseData.weatherCorrectData
            )
        }
        
        // When
        weatherService.getWeatherOf(city: .nyc) { bpnError, weatherHTTPData in
            // Then
            let weatherDescription = "nuageux"
            let icon = "04d"
            let temp: Float = 23.78
            let tempMin: Float = 19.97
            let tempMax: Float = 26.93
            let dt: Int64 = 1625415627
            let sunrise: Int64 = 1625391011
            let sunset: Int64 = 1625445026
            let timezone: Int64 = -14400
            let id: Int64 = 5128581
            
            XCTAssertNil(bpnError)
            XCTAssertNotNil(weatherHTTPData)
            
            XCTAssertEqual(
                weatherHTTPData?.weather[0].description,
                weatherDescription
            )
            XCTAssertEqual(
                weatherHTTPData?.weather[0].icon,
                icon
            )
            XCTAssertEqual(
                weatherHTTPData?.main.temp,
                temp
            )
            XCTAssertEqual(
                weatherHTTPData?.main.temp_min,
                tempMin
            )
            XCTAssertEqual(
                weatherHTTPData?.main.temp_max,
                tempMax
            )
            XCTAssertEqual(
                weatherHTTPData?.dt,
                dt
            )
            XCTAssertEqual(
                weatherHTTPData?.sys.sunrise,
                sunrise
            )
            XCTAssertEqual(
                weatherHTTPData?.sys.sunset,
                sunset
            )
            XCTAssertEqual(
                weatherHTTPData?.timezone,
                timezone
            )
            XCTAssertEqual(
                weatherHTTPData?.id,
                id
            )
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenRequestHasAUnknowdError_WhenGetWeather_ThenUndefinedErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: MockResponseData.undefinedError,
                response: nil,
                data: nil
            )
        }

        // When
        weatherService.getWeatherOf(city: .nyc) { bpnError, weatherHTTPData in
            // Then
            XCTAssertEqual(bpnError, .undefinedRequestError)
            XCTAssertNil(weatherHTTPData)
            
            self.expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeOut)
    }

    func testGivenBadURL_WhenGetWeather_ThenBadURLErrorIsThrown() {
        // Given
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession.init(configuration: configuration)

        weatherService = WeatherService(
            session: session,
            apiURL: MockResponseData.badURL
        )

        // When
        weatherService.getWeatherOf(city: .nyc) { bpnError, weatherHTTPData in
            // Then
            XCTAssertEqual(bpnError, .undefinedRequestError)
            XCTAssertNil(weatherHTTPData)
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeOut)
    }

    func testGivenRequestHasConnectionError_WhenGetWeather_ThenConnectionErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: MockResponseData.internetConnectionError,
                response: nil,
                data: nil
            )
        }
        // When
        weatherService.getWeatherOf(city: .nyc) { bpnError, weatherHTTPData in
            // Then
            XCTAssertEqual(bpnError, .internetConnection)
            XCTAssertNil(weatherHTTPData)
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGivenBadResponseData_WhenGetWeather_ThenIncorrectDataErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseOK,
                data: MockResponseData.incorrectData
            )
        }
        
        // When
        weatherService.getWeatherOf(city: .nyc) { bpnError, weatherHTTPData in
            // Then
            XCTAssertNotNil(bpnError)
            XCTAssertNil(weatherHTTPData)
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenNoResponseData_WhenGetWeather_ThenResponseDataErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseOK,
                data: nil
            )
        }
        // When
        weatherService.getWeatherOf(city: .nyc) { bpnError, weatherHTTPData in
            // Then
            XCTAssertEqual(bpnError, .httpResponseData)
            XCTAssertNil(weatherHTTPData)
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenBadStatusResponse_WhenGetWeather_ThenStatusCodeErrorIsThrown() {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: MockResponseData.responseKO,
                data: nil
            )
        }

        // When
        weatherService.getWeatherOf(city: .nyc) { bpnError, weatherHTTPData in
            // Then
            XCTAssertEqual(bpnError, .httpStatusCode)
            XCTAssertNil(weatherHTTPData)
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeOut)
    }
    
    func testGivenNoResponse_WhenGetWeather_ThenResponseErrorIsThrown() {
        // Giventm
        MockURLProtocol.requestHandler = { request in
            return (
                error: nil,
                response: nil,
                data: nil
            )
        }

        // When
        weatherService.getWeatherOf(city: .nyc) { bpnError, weatherHTTPData in
            // Then
            XCTAssertEqual(bpnError, .httpResponse)
            XCTAssertNil(weatherHTTPData)
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeOut)
    }
}
