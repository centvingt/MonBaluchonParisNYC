//
//  URLSessionFake.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 14/06/2021.
//

import Foundation

// MARK: - Not iOS 13.0 friendly

//class URLSessionFake: URLSession {
//    var data: Data?
//    var response: URLResponse?
//    var error: Error?
//
//    init(data: Data?, response: URLResponse?, error: Error?) {
//        self.data = data
//        self.response = response
//        self.error = error
//    }
//
//    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        let task = URLSessionDataTaskFake()
//        task.completionHander = completionHandler
//        task.data = data
//        task.urlResponse = response
//        task.responseError = error
//        return task
//    }
//
//    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        let task = URLSessionDataTaskFake()
//        task.completionHander = completionHandler
//        task.data = data
//        task.urlResponse = response
//        task.responseError = error
//        return task
//    }
//}
//
//class URLSessionDataTaskFake: URLSessionDataTask {
//    var completionHander: ((Data?, URLResponse?, Error?) -> Void)?
//    var data: Data?
//    var urlResponse: URLResponse?
//    var responseError: Error?
//
//    override func resume() {
//        completionHander?(data, urlResponse, responseError)
//    }
//
//    override func cancel() {}
//}


// MARK: - iOS 13.0 friendly


class MockURLProtocol: URLProtocol {
    // 1. Handler to test the request and return mock response.
    static var requestHandler: ((URLRequest) throws -> (error: URLError?, response: HTTPURLResponse?, data: Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        // To check if this protocol can handle the given request.
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Here you return the canonical version of the request but most of the time you pass the orignal one.
        return request
    }

    override func startLoading() {
        // This is where you create the mock response as per your test case and send it to the URLProtocolClient.
        guard let handler = MockURLProtocol.requestHandler else {
            return
        }
        
        do {
            // 2. Call handler with received request and capture the tuple of response and data.
            let (error, response, data) = try handler(request)

            // 3. Send received response to the client.
            if let error = error {
                throw error
            }
            
            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = data {
                // 4. Send received data to the client.
                client?.urlProtocol(self, didLoad: data)
            }

            // 5. Notify request has been finished.
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // 6. Notify received error.
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // This is called if the request gets canceled or completed.
    }
}
//
//class URLProtocolMock: URLProtocol {
//    /// Dictionary maps URLs to tuples of error, data, and response
//    static var mockURLs = [URL?: (error: Error?, data: Data?, response: HTTPURLResponse?)]()
//
//    override class func canInit(with request: URLRequest) -> Bool {
//        // Handle all types of requests
//        return true
//    }
//
//    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
//        // Required to be implemented here. Just return what is passed
//        return request
//    }
//
//    override func startLoading() {
//        if let url = request.url {
//            if let (error, data, response) = URLProtocolMock.mockURLs[url] {
//
//                // We have a mock response specified so return it.
//                if let responseStrong = response {
//                    self.client?.urlProtocol(self, didReceive: responseStrong, cacheStoragePolicy: .notAllowed)
//                }
//
//                // We have mocked data specified so return it.
//                if let dataStrong = data {
//                    self.client?.urlProtocol(self, didLoad: dataStrong)
//                }
//
//                // We have a mocked error so return it.
//                if let errorStrong = error {
//                    self.client?.urlProtocol(self, didFailWithError: errorStrong)
//                }
//            }
//        }
//
//        // Send the signal that we are done returning our mock response
//        self.client?.urlProtocolDidFinishLoading(self)
//    }
//
//    override func stopLoading() {
//        // Required to be implemented. Do nothing here.
//    }
//}
