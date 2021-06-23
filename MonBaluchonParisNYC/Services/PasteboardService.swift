//
//  PasteboardService.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 10/06/2021.
//

import UIKit

struct PasteboardService: PasteboardServiceProtocol {
    func set(value: String) {
        UIPasteboard.general.string = value
    }
    func fetchValue() -> String? {
        guard UIPasteboard.general.hasStrings else {
            return nil
        }
        return UIPasteboard.general.string
    }
}

protocol PasteboardServiceProtocol {
    func set(value: String)
    func fetchValue() -> String?
}
