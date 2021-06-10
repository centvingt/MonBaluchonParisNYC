//
//  PasteboardService.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 10/06/2021.
//

import UIKit

struct PasteboardService {
    static func set(value: String) {
        UIPasteboard.general.string = value
    }
}
