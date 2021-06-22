//
//  BPNError.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

enum BPNError {
    case apiKeysNoFilePhath,
         apiURLRequest,
         internetConnection,
         undefinedRequestError,
         httpResponse,
         httpStatusCode,
         httpResponseData
}
