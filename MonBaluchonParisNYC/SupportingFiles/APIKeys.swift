//
//  APIKeys.swift
//  LeBaluchon
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import Foundation

func valueForAPIKey(named keyname:String) -> String {
    let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    let value = plist?.object(forKey: keyname) as! String
    return value
}

let KeyCurrency = valueForAPIKey(named: "Fixer")
let KeyTranslate = valueForAPIKey(named: "GoogleTranslate")
let KeyWeather = valueForAPIKey(named: "OpenWeather")
