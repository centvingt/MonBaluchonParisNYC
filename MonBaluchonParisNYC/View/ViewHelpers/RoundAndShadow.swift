//
//  RoundAndShadow.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 03/06/2021.
//

import UIKit

func getBPNRadius() -> CGFloat {
    return 6
}

func setRoundedAndShadowFor(_ view: UIView) {
    view.layer.cornerRadius = getBPNRadius()
    
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    view.layer.shadowOpacity = 0.24
    view.layer.shadowRadius = 4.0
}
