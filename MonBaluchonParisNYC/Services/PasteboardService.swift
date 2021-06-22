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
    static func fetchValue() -> String? {
        if UIPasteboard.general.hasStrings {
            return UIPasteboard.general.string
        } else { return nil }
    }
}
