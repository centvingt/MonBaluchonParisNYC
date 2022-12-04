//
//  WeatherService.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

class WeatherService: WeatherServiceProtocol {
    static let shared = WeatherService()
    private init() {}
    
    private var session = URLSession(configuration: .default)
    private var task: URLSessionDataTask?
    
    private var apiURL: String = "https://api.openweathermap.org/data/2.5/weather"
    
    init(
        session: URLSession = URLSession.shared,
        apiURL: String
    ) {
        self.session = session
        self.apiURL = apiURL
    }
    
    func getWeatherOf(
        city: City,
        completion: @escaping (BPNError?, WeatherHTTPData?) -> ()
    ) {
        guard let apiKeyWeather = apiKeyWeather,
              let url = URL(string: "\(apiURL)?id=\(city.getCityWeatherID())&lang=fr&units=metric&appid=\(apiKeyWeather)")
        else {
            completion(BPNError.undefinedRequestError, nil)
            return
        }
        
        task?.cancel()
        task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                print("WeatherService ~> getWeatherOf ~> NEW WEATHER REQUEST")
                
                // HTTP request's handling
                if let error = error as? URLError {
                    if error.code == URLError.Code.notConnectedToInternet {
                        completion(BPNError.internetConnection, nil)
                        return
                    } else {
                        completion(BPNError.undefinedRequestError, nil)
                        return
                    }
                }
                
                // Getting HTTP response
                guard let response = response as? HTTPURLResponse else {
                    completion(BPNError.httpResponse, nil)
                    return
                }
                
                guard response.statusCode == 200 else {
                    completion(BPNError.httpStatusCode, nil)
                    return
                }
                
                guard let data = data,
                      let weatherHTTPData = try?
                        JSONDecoder()
                        .decode(
                            WeatherHTTPData.self,
                            from: data
                        ) else {
                    completion(BPNError.httpResponseData, nil)
                    return
                }
                
                completion(nil, weatherHTTPData)
            }
        }
        task?.resume()
    }
}

protocol WeatherServiceProtocol {
    func getWeatherOf(
        city: City,
        completion: @escaping (BPNError?, WeatherHTTPData?) -> ()
    )
}
