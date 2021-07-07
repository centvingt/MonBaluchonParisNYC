//
//  WeatherCell.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 07/07/2021.
//

import UIKit

class WeatherCell: UITableViewCell {
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var tempMinContainer: UIView!
    @IBOutlet weak var tempMaxContainer: UIView!
    @IBOutlet weak var sunriseContainer: UIView!
    @IBOutlet weak var sunsetContainer: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    // MARK: - Configuration
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        configureUI()
    }
    
    func configureUI() {
        ViewHelper.setRoundedAndShadowFor(view: mainContainer)
        ViewHelper.setRoundedAndShadowFor(view: headerContainer)
        ViewHelper.setRoundedAndShadowFor(view: tempMinContainer)
        ViewHelper.setRoundedAndShadowFor(view: tempMaxContainer)
        ViewHelper.setRoundedAndShadowFor(view: sunriseContainer)
        ViewHelper.setRoundedAndShadowFor(view: sunsetContainer)
    }
}
