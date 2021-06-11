//
//  Haptic.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 11/06/2021.
//

import UIKit

struct Haptic {
    private let haptic = UINotificationFeedbackGenerator()
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    

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
