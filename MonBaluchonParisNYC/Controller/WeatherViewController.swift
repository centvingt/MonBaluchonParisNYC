//
//  WeatherViewController.swift
//  LeBaluchon
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import UIKit

class WeatherViewController: UITableViewController {
    var weatherData: WeatherHTTPData?
    var dateData: String?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private let userDefaults = UserDefaults()
    private let cityUDKey = "city"
    private var city: City {
        get {
            guard let userDefaultsCity = userDefaults.string(forKey: cityUDKey) else {
                return .nyc
            }
            if userDefaultsCity == City.paris.rawValue {
                return .paris
            } else {
                return .nyc
            }
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: cityUDKey)
        }
    }
    
    private let weather = Weather()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setSegmentedControl()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
            
        if #available(iOS 13.0, *) {
            guard let font = UIFont(name: "SF Compact Rounded", size: 16.0) else {
                print("pas de police")
                return
            }
            
            segmentedControl.selectedSegmentTintColor = UIColor.bpnBleuGoudron
            segmentedControl.setTitleTextAttributes(
                [
                    .foregroundColor: UIColor.bpnBleuGoudron as Any,
                    .font: font
                ],
                for: .normal
            )
            segmentedControl.setTitleTextAttributes(
                [
                    .foregroundColor: UIColor.bpnRoseVille as Any,
                    .font: font
                ],
                for: .selected
            )
        }
        
        weather.getWeatherOf(city: city)
        registerForWeatherDataNotification()
    }
    override func viewWillAppear(_ animated: Bool) {
        setSegmentedControl()
        
        weather.getWeatherOf(city: city)
        registerForWeatherDataNotification()
    }

    // MARK: - Notifications
    private func registerForWeatherDataNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(weatherDataIncoming(_:)),
            name: Notification.Name.weatherData,
            object: nil
        )
    }
    @objc private func weatherDataIncoming(_ notification: NSNotification) {
        guard let weatherData = notification
                .userInfo?["weatherData"] as? WeatherHTTPData,
              let dateData = notification
                .userInfo?["dateData"] as? String
        else { return }
        
        self.weatherData = weatherData
        self.dateData = dateData
        
        print("WeatherViewController ~> weatherDataIncoming ~> weatherData ~>", weatherData)
        print("WeatherViewController ~> weatherDataIncoming ~> dateData ~>", dateData)
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    private func registerForErrorNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentAlert(for:)),
            name: Notification.Name.errorInternetConnection,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentAlert(for:)),
            name: Notification.Name.errorUndefined,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentAlert(for:)),
            name: Notification.Name.errorBadPasteboardValue,
            object: nil
        )
    }
    
    @objc private func presentAlert(for notification: Notification) {
        var title = ""
        var message = ""
        
        if notification.name == .errorInternetConnection {
            title = "Pas de connection internet"
            message = "Activez votre connexion internet avant d’utiliser l’application."
        }
        if notification.name == .errorUndefined {
            title = "Erreur"
            message = "Une erreur indéterminée est survenue."
        }
        if notification.name == .errorBadPasteboardValue {
            title = "Mauvaise donnée"
            message = "Veuillez coller un nombre dans ce champ."
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
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func segmentedChanged(_ sender: Any) {
        city = getCityFromSegmentedControl()
        
        weather.getWeatherOf(city: city)
        registerForWeatherDataNotification()
        
        tableView.reloadData()
    }
    private func getCityFromSegmentedControl() -> City {
        return segmentedControl.selectedSegmentIndex == 0 ? .paris : .nyc
    }
    
    // MARK: - Segmented controll handler
    @objc private func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            segmentedControl.selectedSegmentIndex = 0
        }
        if (sender.direction == .right) {
            segmentedControl.selectedSegmentIndex = 1
        }
        city = getCityFromSegmentedControl()
        tableView.reloadData()
    }
    private func setSegmentedControl() {
        switch city {
        case .paris:
            segmentedControl.selectedSegmentIndex = 0
        case .nyc:
            segmentedControl.selectedSegmentIndex = 1
        }
    }
 
}
