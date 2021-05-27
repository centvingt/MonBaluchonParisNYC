//
//  ViewController.swift
//  LeBaluchon
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import UIKit

class CurrencyViewController: UIViewController {
    @IBOutlet weak var tableView: SelfSizedTableView!
    @IBOutlet weak var header: UIView!
    
//    private var currencyRate = CurrencyConversion()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currencyRateDataIsSet(_:)),
            name: Notification.Name.currencyRateData,
            object: nil
        )
        
//        currencyRate.setRate()
        tableView.separatorInset = UIEdgeInsets(top: 4, left: 15, bottom: 8, right: 0);
        
        setRoundedAndShadowFor(tableView)
        setRoundedAndShadowFor(header)
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

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 2
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "navCell") else {
            return UITableViewCell.init()
        }
        
        cell.accessoryType = .disclosureIndicator
        let chevron = UIImage(named: "Chevron")
        cell.accessoryView = UIImageView(image: chevron!)
        cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 11.2543, height: 20)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Conversion $/€"
            let cellSize = UIScreen.main.bounds
            let separatorHeight = CGFloat(2.0)
            let additionalSeparator = UIView.init(
                frame: CGRect(
                    x: 15,
                    y: cell.frame.size.height - separatorHeight,
                    width: cellSize.width,
                    height: separatorHeight
                )
            )
            additionalSeparator.backgroundColor = UIColor.bpnRoseVille
            additionalSeparator.layer.cornerRadius = 1
            cell.addSubview(additionalSeparator)
        case 1:
            cell.textLabel?.text = "Calcul de la TVA"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            return UITableViewCell.init()
        }
        
        
        
        return cell
    }
}

func setRoundedAndShadowFor(_ view: UIView) {
    view.layer.cornerRadius = 6
    
//    view.layer.shadowColor = UIColor.black.cgColor
//    view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//    view.layer.shadowOpacity = 0.24
//    view.layer.shadowRadius = 4.0
}
