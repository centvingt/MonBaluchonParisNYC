//
//  ViewController.swift
//  LeBaluchon
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import UIKit

class CurrencyViewController: UIViewController {
    private var currencyRate = CurrencyConversion()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("viewDidLoad")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currencyRateDataIsSet(_:)),
            name: Notification.Name.currencyRateData,
            object: nil
        )
        
        currencyRate.setRate()
    }
    
    @objc private func currencyRateDataIsSet(_ notification: NSNotification) {
        print("CurrencyViewController ~> currencyRateDataIsSet", notification.userInfo?["euroToUSDRate"])
        guard let euroToUSDRate = notification.userInfo?["euroToUSDRate"] as? Float,
              let usdToEuroRate = notification.userInfo?["usdToEuroRate"] as? Float,
              let date = notification.userInfo?["date"] as? Int
              else {
            print("notification mais pas de données")
            return
        }
        print("self.euroToUSDRate", euroToUSDRate)
        print("self.usdToEuroRate", usdToEuroRate)
        print("self.date", date)

    }
}

