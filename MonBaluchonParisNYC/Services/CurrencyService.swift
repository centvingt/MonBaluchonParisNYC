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
    
    //    private var apiURL: String = "https://fixer-io-request.herokuapp.com/?key=13E1D8BB-A38D-4F38-A264-E29DAE7F1FA4"
    private var apiURL: String = "https://api.frankfurter.app/latest?to=USD"
    
    
    /* https://api.frankfurter.app/latest?amount=${fromValue}&from=${currencyFrom}&to=${currencyTo} */
    /* https://api.frankfurter.app/latest?to=USD */
    
    //    struct CurrencyRateHTTPData: Decodable {
    //        let success: Bool
    //        let date: String
    //        let rates: Rates
    //
    //        struct Rates: Decodable {
    //            let USD: Double
    //        }
    //    }
    
    
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
                
                // Getting JSON from HTTP response
                guard let data = data,
                      let currencyRateData = try? JSONDecoder()
                    .decode(
                        CurrencyRateHTTPData.self,
                        from: data
                    )
                else {
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
