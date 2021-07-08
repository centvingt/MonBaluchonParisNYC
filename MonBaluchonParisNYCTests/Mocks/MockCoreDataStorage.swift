//
//  MockCoreDataStorage.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 08/07/2021.
//

@testable import MonBaluchonParisNYC

class MockCoreDataStorage: CoreDataStorageProtocol {
    var parisWeatherHttpData: WeatherHTTPData?
    var nycWeatherHttpData: WeatherHTTPData?
    
    let parisID = City.paris.getCityWeatherID()
    let nycID = City.nyc.getCityWeatherID()
    
    func saveWeather(_ weather: WeatherHTTPData) {
        switch weather.id {
        case parisID:
            parisWeatherHttpData = weather
        case nycID:
            nycWeatherHttpData = weather
        default:
            return
        }
    }
    
    func getWeatherOfCity(id: Int64) -> WeatherHTTPData? {
        switch id {
        case parisID:
            return parisWeatherHttpData
        case nycID:
            return nycWeatherHttpData
        default:
            return nil
        }
    }
}
