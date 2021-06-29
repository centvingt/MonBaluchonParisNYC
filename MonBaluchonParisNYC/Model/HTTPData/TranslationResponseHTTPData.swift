//
//  TranslationResponseHTTPData.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 26/06/2021.
//

import Foundation

struct TranslationResponseHTTPData: Decodable {
    let data: Data
    
    struct Data: Decodable {
        let translations: [Translations]
        
        struct Translations: Decodable {
            let translatedText: String
        }
    }
}

/*
{
 "data": {
   "translations": [
     {
       "translatedText": "La grande pyramide de Gizeh (également connue sous le nom de pyramide de Khéops ou pyramide de Khéops) est la plus ancienne et la plus grande des trois pyramides du complexe pyramidal de Gizeh."
     }
   ]
 }
}
*/
