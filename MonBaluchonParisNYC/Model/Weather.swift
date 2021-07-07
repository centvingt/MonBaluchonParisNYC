//
//  Weather.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 04/07/2021.
//

import Foundation

class Weather {
    // MARK: - Dependency injection
    
    private let weatherService: WeatherServiceProtocol
    
    private let coreDataStorage = CoreDataStorage()
    
    init(
        weatherService: WeatherServiceProtocol = WeatherService.shared
    ) {
        self.weatherService = weatherService
    }
    
    // MARK: - Service request
    
    func getWeatherOf(city: City) {
        print("Weather ~> getWeatherOf")
        
        // 43200000 is equal to 12 hours
        if let weatherHTTPData = coreDataStorage.getWeatherOfCity(id: city.getCityWeatherID()),
           weatherHTTPData.dt + 43200000 < Int64(currentDate.value().timeIntervalSince1970) {
            postDataNotification(
                weatherHTTPData: weatherHTTPData,
                for: city
            )
            return
        }
        
        weatherService.getWeatherOf(city: city) { bpnError, weatherHTTPData in
            if let bpnError = bpnError {
                // TODO: poster des notifications avec les erreurs
                if bpnError == .internetConnection {
                    print("Weather ~> getWeatherOf ~> bpnError.internetConnection")
                } else {
                    print("Weather ~> getWeatherOf ~> bpnError.errorUndefined")
                }
                return
            }
            
            guard let weatherHTTPData = weatherHTTPData else {
                // TODO: poster une notification avec l’erreur
                print("Weather ~> getWeatherOf ~> erreur data")
                return
            }
            
            self.coreDataStorage.saveWeather(weatherHTTPData)
            self.postDataNotification(weatherHTTPData: weatherHTTPData, for: city)
        }
    }
    
    // MARK: - Post notifications
    
    private func postDataNotification(
        weatherHTTPData: WeatherHTTPData,
        for city: City
    ) {
        print("Weather ~> postDataNotification")
        NotificationCenter.default.post(
            name: .weatherData,
            object: self,
            userInfo: [
                "weatherData": weatherHTTPData,
                "dateData": getFormatedDate(
                    from: weatherHTTPData.dt,
                    with: weatherHTTPData.timezone,
                    for: city
                )
            ]
        )
    }
    
    // MARK: - Date helper
    
    private func getFormatedDate(
        from timestamp: Int64,
        with timezone: Int64,
        for city: City
    ) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr-FR")
        formatter.dateFormat = "eeee d MMMM yyyy 'à' H 'h' mm 'heure de \(city.rawValue)'"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timezone))
        
        return formatter.string(from: date)
    }
}
