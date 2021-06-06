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
        // Initialization code
        setRoundedAndShadowFor(view: background)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(
        city: City,
        rate: String,
        rateDate: String
    ) {
        introLabel.text = "Un \(city == .paris ? "euro" : "dollar") équivaut à"
        rateLabel.text = "\(rate) \(city == .paris ? "$" : "€")"
        dateLabel.text = "Dernière mise à jour le \(rateDate)"
    }
}
