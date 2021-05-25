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
         httpInternetConnection,
         httpResponse,
         httpStatusCode,
         httpResponseData
}
