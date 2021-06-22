//
//  RoundAndShadow.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 03/06/2021.
//

import UIKit

struct ViewHelper {
    static func getBPNRadius() -> CGFloat {
        return 8
    }
    static func getBPNWidth() -> CGFloat {
        return 1
    }

    static func setRoundedAndShadowFor(view: UIView) {
        view.layer.cornerRadius = getBPNRadius()
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        view.layer.shadowOpacity = 0.24
        view.layer.shadowRadius = 4.0
    }

    static func setRoundedAndBorderFor(view: UIView, with color: CGColor) {
        view.layer.borderWidth = getBPNWidth()
        view.layer.cornerRadius = getBPNRadius()
        view.layer.borderColor = color
        
        view.clipsToBounds = true
    }
}

