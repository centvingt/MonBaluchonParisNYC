//
//  WeatherTestCase.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 08/07/2021.
//

@testable import MonBaluchonParisNYC
import XCTest

class WeatherTestCase: XCTestCase {
    var sut = Weather()
    
    var coreDataStorage = MockCoreDataStorage()
    var weatherService = MockWeatherService()
    
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
    
    var weatherDescription: String?
    var date: String?
    var iconName: String?
    var temp: String?
    var tempMin: String?
    var tempMax: String?
    var sunrise: String?
    var sunset: String?
    
    var expectedValueOfWeatherDescription = "Nuageux"
    var expectedValueOfDate = "Dernière mise à jour le dimanche 4 juillet 2021\nà 12 h 20, heure de New-York"
    var expectedValueOfIconName = "04d"
    var expectedValueOfTemp = "24 °C"
    var expectedValueOfTempMin = "20 °C (min.)"
    var expectedValueOfTempMax = "27 °C (max.)"
    var expectedValueOfSunrise = "5 h 30 (lever)"
    var expectedValueOfSunset = "20 h 30 (coucher)"
    
    let timeout = 1.0
    
    // Check that a notification has been posted
    var notification: NSNotification?
    
    // setUp() is executed before each test
    override func setUp() {
        super.setUp()
        
        coreDataStorage = MockCoreDataStorage()
        weatherService = MockWeatherService()
        
        sut = Weather(
            weatherService: weatherService,
            coreDataStorage: coreDataStorage
        )
        
        notification = nil
        
        weatherHTTPData = WeatherHTTPData(
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
        
        currentDate = CurrentDate.mockDate20210512
    }
    
    /* notificationPosted() is executed
     when a notification is observed */
    @objc func notificationPosted(_ notification: NSNotification) {
        self.notification = notification
        
        if notification.name == .weatherData {
            guard let weatherDescription = notification
                    .userInfo?["weatherDescription"] as? String,
                  let date = notification
                    .userInfo?["date"] as? String,
                  let iconName = notification
                    .userInfo?["iconName"] as? String,
                  let temp = notification
                    .userInfo?["temp"] as? String,
                  let tempMin = notification
                    .userInfo?["tempMin"] as? String,
                  let tempMax = notification
                    .userInfo?["tempMax"] as? String,
                  let sunrise = notification
                    .userInfo?["sunrise"] as? String,
                  let sunset = notification
                    .userInfo?["sunset"] as? String
            else { return }
            
            self.weatherDescription = weatherDescription
            self.date = date
            self.iconName = iconName
            self.temp = temp
            self.tempMin = tempMin
            self.tempMax = tempMax
            self.sunrise = sunrise
            self.sunset = sunset
        }
    }
    
    func testGivenCurrentDateDontExceedStoredDate_WhenGetWeather_ThenReturnStoredData() {
        // Given
        coreDataStorage.nycWeatherHttpData = weatherHTTPData
        currentDate = .mockDate20210511
        
        // When
        let notificationName = Notification.Name.weatherData
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getWeatherOf(city: .nyc)
        
        // Then
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            
            XCTAssertEqual(self.notification?.name, .weatherData)
            
            XCTAssertEqual(
                self.weatherDescription,
                self.expectedValueOfWeatherDescription
            )
            XCTAssertEqual(
                self.date,
                self.expectedValueOfDate
            )
            XCTAssertEqual(
                self.iconName,
                self.expectedValueOfIconName
            )
            XCTAssertEqual(
                self.temp,
                self.expectedValueOfTemp
            )
            XCTAssertEqual(
                self.tempMin,
                self.expectedValueOfTempMin
            )
            XCTAssertEqual(
                self.tempMax,
                self.expectedValueOfTempMax
            )
            XCTAssertEqual(
                self.sunrise,
                self.expectedValueOfSunrise
            )
            XCTAssertEqual(
                self.sunset,
                self.expectedValueOfSunset
            )
        }
    }
    
    func testGivenGetWeatherReturnInternetConnectionError_WhenGetWeather_ThenReturnError() {
        // Given
        weatherService.bpnError = .internetConnection
        
        // When
        let notificationName = Notification.Name.errorInternetConnection
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getWeatherOf(city: .nyc)
        
        // Then
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssertEqual(self.notification?.name, .errorInternetConnection)
        }
    }
    
    func testGivenGetWeatherReturnUndefinedError_WhenGetWeather_ThenReturnError() {
        // Given
        weatherService.bpnError = .undefinedRequestError
        
        // When
        let notificationName = Notification.Name.errorUndefined
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getWeatherOf(city: .nyc)
        
        // Then
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssertEqual(self.notification?.name, .errorUndefined)
        }
    }
    
    func testGivenGetWeatherReturnNoData_WhenGetWeather_ThenReturnError() {
        // Given
        weatherService.weatherHTTPData = nil
        
        // When
        let notificationName = Notification.Name.errorUndefined
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getWeatherOf(city: .nyc)
        
        // Then
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            XCTAssertEqual(self.notification?.name, .errorUndefined)
        }
    }
    
    func testGivenGetWeatherReturnData_WhenGetWeather_ThenReturnCorrectData() {
        // Given
        weatherService.weatherHTTPData = weatherHTTPData
        
        // When
        let notificationName = Notification.Name.weatherData
        expectation(
            forNotification: notificationName,
            object: nil,
            handler: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: notificationName,
            object: nil
        )
        
        sut.getWeatherOf(city: .nyc)
        
        // Then
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("timeout errored: \(error)")
                return
            }
            
            XCTAssertEqual(self.notification?.name, .weatherData)
            
            XCTAssertEqual(
                self.weatherDescription,
                self.expectedValueOfWeatherDescription
            )
            XCTAssertEqual(
                self.date,
                self.expectedValueOfDate
            )
            XCTAssertEqual(
                self.iconName,
                self.expectedValueOfIconName
            )
            XCTAssertEqual(
                self.temp,
                self.expectedValueOfTemp
            )
            XCTAssertEqual(
                self.tempMin,
                self.expectedValueOfTempMin
            )
            XCTAssertEqual(
                self.tempMax,
                self.expectedValueOfTempMax
            )
            XCTAssertEqual(
                self.sunrise,
                self.expectedValueOfSunrise
            )
            XCTAssertEqual(
                self.sunset,
                self.expectedValueOfSunset
            )
        }
    }
}
