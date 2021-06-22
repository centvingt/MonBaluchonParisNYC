//
//  CurrencyService.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 03/06/2021.
//

import Foundation

class CurrencyService: CurrencyServiceProtocol {
    static let shared = CurrencyService()
    private init() { }
    
    private var session = URLSession(configuration: .default)
    private var task: URLSessionDataTask?
    
    private var apiURL: String = "https://animated-graph-314612.uk.r.appspot.com/?key=devkey"
    
    init(
        session: URLSession = URLSession.shared,
        apiURL: String
    ) {
        self.session = session
        self.apiURL = apiURL
    }
    
    func getRate(completion: @escaping (BPNError?, CurrencyRateHTTPData?) -> ()) {
        guard let url = URL(string: apiURL) else {
            print("URL ERROR")
            completion(BPNError.apiURLRequest, nil)
            return
        }
        
        task?.cancel()
        task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                // HTTP request's handling
                if let error = error as? URLError {
                    if error.code == URLError.Code.notConnectedToInternet {
                        print("ERROR BECAUSE NOT CONNECTED TO INTERNET")
                        completion(BPNError.internetConnection, nil)
                        return
                    } else {
                        print("UNDEFINED REQUEST ERROR")
                        completion(BPNError.undefinedRequestError, nil)
                        return
                    }
                }
                
                // Getting HTTP response
                guard let response = response as? HTTPURLResponse else {
                    print("ERROR WITH THE RESPONSE")
                    completion(BPNError.httpResponse, nil)
                    return
                }
                
                guard response.statusCode == 200 else {
                    print("ERROR WITH THE RESPONSE'S STATUS CODE", response.statusCode)
                    completion(BPNError.httpStatusCode, nil)
                    return
                }
                
                // Getting JSON from HTTP response
                guard let data = data,
                      let currencyRateData = try? JSONDecoder().decode(CurrencyRateHTTPData.self, from: data) else {
                    print("ERROR WITH THE DATA")
                    completion(BPNError.httpResponseData, nil)
                    return
                }
                
                completion(nil, currencyRateData)
            }
        }
        task?.resume()
    }
}

protocol CurrencyServiceProtocol {
    func getRate(completion: @escaping (BPNError?, CurrencyRateHTTPData?) -> ())
}
