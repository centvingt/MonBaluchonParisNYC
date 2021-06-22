//
//  CurrencyRateCell.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 01/06/2021.
//

import UIKit

class CurrencyRateCell: UITableViewCell {
    @IBOutlet private weak var introLabel: UILabel!
    @IBOutlet private weak var rateLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var background: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        ViewHelper.setRoundedAndShadowFor(view: background)
    }
    
    func configure(
        city: City,
        rate: String,
        rateDate: String
    ) {
        introLabel.text = "Un \(city.getCurrency().name) équivaut à"
        rateLabel.text = "\(rate) \(city.getCurrency().convertSymbol)"
        dateLabel.text = "Dernière mise à jour le \(rateDate)"
    }
}
