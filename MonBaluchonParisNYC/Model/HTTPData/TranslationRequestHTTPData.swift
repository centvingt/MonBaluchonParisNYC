//
//  TranslationRequestHTTPData.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 26/06/2021.
//

import Foundation

struct TranslationRequestHTTPData: Encodable {
    let q: String
    let source: String
    let target: String
    let format = "text"
    
    init(
        q: String,
        source: TranslationLanguage,
        target: TranslationLanguage
    ) {
        self.q = q
        self.source = source.rawValue
        self.target = target.rawValue
    }
}

/* {
  "q": "The Great Pyramid of Giza (also known as the Pyramid of Khufu or the Pyramid of Cheops) is the oldest and largest of the three pyramids in the Giza pyramid complex.",
  "source": "en",
  "target": "fr",
  "format": "text"
}*/
