//
//  Weather.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 04/07/2021.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

//    mutating func capitalizeFirstLetter() {
//        self = self.capitalizingFirstLetter()
//    }
}

class Weather {
    // MARK: - Dependency injection
    
    private let weatherService: WeatherServiceProtocol
    private let coreDataStorage: CoreDataStorageProtocol
    
    init(
        weatherService: WeatherServiceProtocol = WeatherService.shared,
        coreDataStorage: CoreDataStorageProtocol = CoreDataStorage()
    ) {
        self.weatherService = weatherService
        self.coreDataStorage = coreDataStorage
    }
    
    // MARK: - Service request
    
    func getWeatherOf(city: City) {
        // 43200000 is equal to 12 hours
        if let weatherHTTPData = coreDataStorage
            .getWeatherOfCity(id: city.getCityWeatherID()),
           weatherHTTPData.dt + 43200000 > Int64(
            currentDate.value()
                .timeIntervalSince1970
           ) {
            postDataNotification(
                weatherHTTPData: weatherHTTPData,
                for: city
            )
            return
        }
        
        weatherService.getWeatherOf(city: city) { bpnError, weatherHTTPData in
            if let bpnError = bpnError {
                var notification: Notification
                if bpnError == .internetConnection {
                    notification = Notification(name: .errorInternetConnection)
                } else {
                    notification = Notification(name: .errorUndefined)
                }
                NotificationCenter.default.post(notification)
                return
            }
            
            guard let weatherHTTPData = weatherHTTPData else {
                // TODO: poster une notification avec l’erreur
                print("Weather ~> getWeatherOf ~> DATA ERROR")
                NotificationCenter.default.post(Notification(name: .errorUndefined))
                return
            }
            
            self.coreDataStorage.saveWeather(weatherHTTPData)
            self.postDataNotification(weatherHTTPData: weatherHTTPData, for: city)
        }
    }
    
    // MARK: - Post notifications
    
    private enum Moment: String {
        case sunrise = "lever",
             sunset = "coucher"
    }
    
    private enum TempBoundary {
        case min, max
    }
    
    private func postDataNotification(
        weatherHTTPData: WeatherHTTPData,
        for city: City
    ) {
        NotificationCenter.default.post(
            name: .weatherData,
            object: self,
            userInfo: [
                "weatherDescription": weatherHTTPData
                    .weather[0]
                    .description
                    .capitalizingFirstLetter(),
                "date": getFormatedDate(
                    from: weatherHTTPData.dt,
                    with: weatherHTTPData.timezone,
                    for: city
                ),
                "iconName": weatherHTTPData.weather[0].icon,
                "temp": getFormatedTemp(
                    weatherHTTPData.main.temp,
                    for: nil
                ),
                "tempMin": getFormatedTemp(
                    weatherHTTPData.main.temp_min,
                    for: .min
                ),
                "tempMax": getFormatedTemp(
                    weatherHTTPData.main.temp_max,
                    for: .max
                ),
                "sunrise": getFormatedHour(
                    from: weatherHTTPData.sys.sunrise,
                    with: weatherHTTPData.timezone,
                    for: .sunrise
                ),
                "sunset": getFormatedHour(
                    from: weatherHTTPData.sys.sunset,
                    with: weatherHTTPData.timezone,
                    for: .sunset
                )
            ]
        )
    }
    
    // MARK: - Notification helpers
    
    private func getFormatedDate(
        from timestamp: Int64,
        with timezone: Int64,
        for city: City
    ) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr-FR")
        formatter.dateFormat = """
            'Dernière mise à jour le' eeee d MMMM yyyy
            'à' H 'h' mm', heure de \(city.rawValue)'
            """
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timezone))
        
        return formatter.string(from: date)
    }
    
    private func getFormatedHour(
        from timestamp: Int64,
        with timezone: Int64,
        for moment: Moment
    ) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr-FR")
        formatter.dateFormat = "H 'h' mm '(\(moment.rawValue))'"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timezone))
        
        return formatter.string(from: date)
    }
    
    private func getFormatedTemp(
        _ temp: Float,
        for tempBoundary: TempBoundary?
    ) -> String {
        var complement: String
        
        switch tempBoundary {
        case .min:
            complement = " (min.)"
        case .max:
            complement = " (max.)"
        default:
            complement = ""
        }
        
        return "\(Int(temp.rounded())) °C\(complement)"
    }
}
