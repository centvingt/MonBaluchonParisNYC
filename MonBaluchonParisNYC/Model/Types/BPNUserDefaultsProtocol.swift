//
//  BPNUserDefaultsProtocol.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 30/06/2021.
//

import Foundation

protocol BPNUserDefaultsProtocol {
    func set(_ value: Any?, forKey defaultName: String)
    
    func integer(forKey defaultName: String) -> Int
    
    func string(forKey defaultName: String) -> String?
    
    func double(forKey defaultName: String) -> Double
}

extension UserDefaults: BPNUserDefaultsProtocol {}
