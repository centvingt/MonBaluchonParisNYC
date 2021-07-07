//
//  WeatherHTTPData.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 04/07/2021.
//

import Foundation

struct WeatherHTTPData: Decodable {
    let weather: [Weather]
    let main: Main
    let dt: Int64
    let sys: Sys
    let id: Int64
    let timezone: Int64
    
    struct Weather: Decodable {
        let description: String
        let icon: String
    }
    struct Main: Decodable {
        let temp: Float
        let temp_min: Float
        let temp_max: Float
    }
    struct Sys: Decodable {
        let sunrise: Int64
        let sunset: Int64
    }
}

//{
//  "coord": {
//    "lon": -74.006,
//    "lat": 40.7143
//  },
//  "weather": [
//    {
//      "id": 803,
//      "main": "Clouds",
//      "description": "nuageux",
//      "icon": "04d"
//    }
//  ],
//  "base": "stations",
//  "main": {
//    "temp": 23.78,
//    "feels_like": 23.83,
//    "temp_min": 19.97,
//    "temp_max": 26.93,
//    "pressure": 1012,
//    "humidity": 62
//  },
//  "visibility": 10000,
//  "wind": {
//    "speed": 2.57,
//    "deg": 240
//  },
//  "clouds": {
//    "all": 75
//  },
//  "dt": 1625415627,
//  "sys": {
//    "type": 1,
//    "id": 4610,
//    "country": "US",
//    "sunrise": 1625391011,
//    "sunset": 1625445026
//  },
//  "timezone": -14400,
//  "id": 5128581,
//  "name": "New York",
//  "cod": 200
//}
