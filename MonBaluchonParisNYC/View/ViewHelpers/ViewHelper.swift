//
//  RoundAndShadow.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 03/06/2021.
//

import UIKit

struct ViewHelper {
    private let haptic = UINotificationFeedbackGenerator()
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    
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

extension ViewHelper {

    func runWarning() {
        haptic.prepare()
        haptic.notificationOccurred(.warning)
    }
    
    func runLight() {
        lightHaptic.prepare()
        lightHaptic.impactOccurred()
    }
    
    func runHeavy() {
        heavyHaptic.prepare()
        heavyHaptic.impactOccurred()
    }

    func runSuccess() {
        haptic.prepare()
        haptic.notificationOccurred(.success)
    }
    
    func runError() {
        haptic.prepare()
        haptic.notificationOccurred(.error)
    }
}

extension ViewHelper {
    static func getEmptyCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = UIColor.bpnRoseVille
        return cell
    }
}
