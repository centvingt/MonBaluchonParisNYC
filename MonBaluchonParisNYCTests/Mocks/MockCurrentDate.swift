//
//  MockCurrentDate.swift
//  MonBaluchonParisNYCTests
//
//  Created by Vincent Caronnet on 04/07/2021.
//

@testable import MonBaluchonParisNYC
import Foundation

extension CurrentDate {
    static let mockDate20210403 = CurrentDate(
        value: {
            // 03/04/2021 0h00.00
            return Date(timeIntervalSince1970: 1617408000)
        }
    )
    static let mockDate20211002 = CurrentDate(
        value: {
            // 02/10/2021 0h00.00
            return Date(timeIntervalSince1970: 1633132800)
        }
    )
    static let mockDate20210511 = CurrentDate(
        value: {
            // 11/05/2021 0h00.00
            return Date(timeIntervalSince1970: 1620691200)
        }
    )
    static let mockDate20210512 = CurrentDate(
        value: {
            // 12/05/2021 0h00.00
            return Date(timeIntervalSince1970: 1620777600)
        }
    )
}

// 1625415627
