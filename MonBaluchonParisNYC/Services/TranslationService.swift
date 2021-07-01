//
//  TranslationService.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

class TranslationService: TranslationServiceProtocol {
    static let shared = TranslationService()
    private init() {}
    
    private var session = URLSession(configuration: .default)
    
    private var apiURL: URL? {
        guard let apiKeyTranslate = apiKeyTranslate,
              let apiURL = URL(
                string: "https://translation.googleapis.com/language/translate/v2?key=\(apiKeyTranslate)"
              )
        else {
            return nil
        }
        return apiURL
    }
    
    private var task: URLSessionDataTask?
    
    func getTranslation(
        of text: String,
        from: TranslationLanguage,
        to: TranslationLanguage,
        completion: @escaping (BPNError?, String?) -> ()
    ) {
        guard let apiURL = apiURL else {
            completion(BPNError.undefinedRequestError, nil)
            return
        }
        
        let payload = TranslationRequestHTTPData(
            q: text,
            source: from,
            target: to
        )
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.addValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        request.addValue(
            Bundle.main.bundleIdentifier ?? "",
            forHTTPHeaderField: "x-ios-bundle-identifier"
        )
        
        do {
            let jsonReq = try JSONEncoder().encode(payload)
            request.httpBody = jsonReq
        } catch {
            print("TranslationService ~> getTranslation ~> ERROR WITH JSONENCODER")
            completion(BPNError.undefinedRequestError, nil)
        }
        
        task?.cancel()
        task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {// HTTP request's handling
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
                      let translationResponseData = try? JSONDecoder()
                        .decode(
                            TranslationResponseHTTPData.self,
                            from: data
                        ) else {
                    print("ERROR WITH THE DATA")
                    completion(BPNError.httpResponseData, nil)
                    return
                }
                
                completion(nil, translationResponseData.data.translations[0].translatedText)}
        }
        task?.resume()
    }
}

protocol TranslationServiceProtocol {
    func getTranslation(
        of text: String,
        from: TranslationLanguage,
        to: TranslationLanguage,
        completion: @escaping (BPNError?, String?) -> ()
    )
}

/* {
 "q": "The Great Pyramid of Giza (also known as the Pyramid of Khufu or the Pyramid of Cheops) is the oldest and largest of the three pyramids in the Giza pyramid complex.",
 "source": "en",
 "target": "fr",
 "format": "text"
 }*/
/* {
 "data": {
 "translations": [
 {
 "translatedText": "La grande pyramide de Gizeh (également connue sous le nom de pyramide de Khéops ou pyramide de Khéops) est la plus ancienne et la plus grande des trois pyramides du complexe pyramidal de Gizeh."
 }
 ]
 }
 } */
