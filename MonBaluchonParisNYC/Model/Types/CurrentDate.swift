//
//  CurrentDate.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 30/06/2021.
//

import Foundation

struct CurrentDate {
    var value: () -> Date = Date.init
}
var currentDate = CurrentDate()
