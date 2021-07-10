//
//  BPNAlertHelper.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 10/07/2021.
//

import UIKit

class BPNAlertHelper {
    static func getAlert(for notification: Notification) -> UIAlertController {
        var title = ""
        var message = ""
        
        switch notification.name {
        case .errorInternetConnection:
            title = "Pas de connection internet"
            message = "Activez votre connexion internet avant d’utiliser l’application."
        case .errorBadPasteboardValue:
            title = "Mauvaise donnée"
            message = "Veuillez coller un nombre dans ce champ."
        case .errorTranslationRequestLimitExceeded:
            title = "Limite dépassée"
            message = "Vous ne pouvez pas effectuer plus de \(Translation().maxRequestPerDay) traduction par jour, ré-essayez demain."
        default:
            title = "Erreur"
            message = "Une erreur indéterminée est survenue."
        }
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "J’ai compris",
                style: .default,
                handler: nil
            )
        )
        
        return alert
    }
}
