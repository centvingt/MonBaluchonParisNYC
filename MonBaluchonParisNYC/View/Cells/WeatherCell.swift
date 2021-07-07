//
//  WeatherCell.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 07/07/2021.
//

import UIKit

class WeatherCell: UITableViewCell {
    @IBOutlet weak private var mainContainer: UIView!
    @IBOutlet weak private var headerContainer: UIView!
    @IBOutlet weak private var tempMinContainer: UIView!
    @IBOutlet weak private var tempMaxContainer: UIView!
    @IBOutlet weak private var sunriseContainer: UIView!
    @IBOutlet weak private var sunsetContainer: UIView!
    
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var icon: UIImageView!
    @IBOutlet weak private var tempLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    
    @IBOutlet weak private var tempMinLabel: UILabel!
    @IBOutlet weak private var tempMaxLabel: UILabel!
    @IBOutlet weak private var sunriseLabel: UILabel!
    @IBOutlet weak private var sunsetLabel: UILabel!
    
    var weatherDescription: String?
    var date: String?
    var iconName: String?
    var temp: String?
    var tempMin: String?
    var tempMax: String?
    var sunrise: String?
    var sunset: String?
    
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
    
    func configureValues() {
        guard let weatherDescription = weatherDescription,
              let date = date,
              let iconName = iconName,
              let temp = temp,
              let tempMin = tempMin,
              let tempMax = tempMax,
              let sunrise = sunrise,
              let sunset = sunset else {
            // TODO: Poster une notification avec une erreur
            return
        }
        
        descriptionLabel.text = weatherDescription
        icon.image = UIImage(named: iconName)
        tempLabel.text = temp
        dateLabel.text = date
        tempMinLabel.text = tempMin
        tempMaxLabel.text = tempMax
        sunriseLabel.text = sunrise
        sunsetLabel.text = sunset
        
        if iconName.last == "d" {
            headerContainer.backgroundColor = .bpnRoseVille
            descriptionLabel.textColor = UIColor.bpnBleuVille
            icon.tintColor = UIColor.bpnBleuVille
            tempLabel.textColor = UIColor.bpnBleuVille
        } else {
            headerContainer.backgroundColor = .bpnBleuGoudron
            descriptionLabel.textColor = UIColor.bpnBleuVille
            icon.tintColor = UIColor.bpnBleuVille
            tempLabel.textColor = UIColor.bpnBleuVille
        }
    }
}
