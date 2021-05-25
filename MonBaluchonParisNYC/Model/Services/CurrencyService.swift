//
//  CurrencyService.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

struct CurrencyService {
    static let shared = CurrencyService()
    private init() { }
    
    func getRate(completion: @escaping (BPNError?, CurrencyRateHttpData?) -> ()) {
        guard let key = keyCurrency else {
            completion(BPNError.apiKeysNoFilePhath, nil)
            return
        }
        let endPoint = "http://data.fixer.io/api/latest?access_key=\(key)&symbols=USD"
        
        guard let url = URL(string: endPoint) else {
            print("URL ERROR")
            completion(BPNError.apiURLRequest, nil)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                // HTTP request's handling
                if let error = error as? URLError {
                    if error.code == URLError.Code.notConnectedToInternet {
                        print("ERROR BECAUSE NOT CONNECTED TO INTERNET")
                        completion(BPNError.internetConnection, nil)
                        return
                    } else {
                        print("UNDEFINED REQUEST ERROR")
                        completion(BPNError.httpInternetConnection, nil)
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
                      let currencyRateData = try? JSONDecoder().decode(CurrencyRateHttpData.self, from: data) else {
                    print("ERROR WITH THE DATA")
                    completion(BPNError.httpResponseData, nil)
                    return
                }
                
                completion(nil, currencyRateData)
            }
        }
        .resume()
    }
}
