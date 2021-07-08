//
//  WeatherViewController.swift
//  LeBaluchon
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import UIKit

class WeatherViewController: UITableViewController {
    private var weatherDescription: String?
    private var date: String?
    private var iconName: String?
    private var temp: String?
    private var tempMin: String?
    private var tempMax: String?
    private var sunrise: String?
    private var sunset: String?
    
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
        guard let weatherDescription = notification
                .userInfo?["weatherDescription"] as? String,
              let date = notification
                .userInfo?["date"] as? String,
              let iconName = notification
                .userInfo?["iconName"] as? String,
              let temp = notification
                .userInfo?["temp"] as? String,
              let tempMin = notification
                .userInfo?["tempMin"] as? String,
              let tempMax = notification
                .userInfo?["tempMax"] as? String,
              let sunrise = notification
                .userInfo?["sunrise"] as? String,
              let sunset = notification
                .userInfo?["sunset"] as? String
        else { return }
        
        self.weatherDescription = weatherDescription
        self.date = date
        self.iconName = iconName
        self.temp = temp
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.sunrise = sunrise
        self.sunset = sunset
        
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
        
        tableView.reloadData()
    }
    private func getCityFromSegmentedControl() -> City {
        return segmentedControl.selectedSegmentIndex == 0 ? .paris : .nyc
    }
    
    // MARK: - Segmented controll handler
    @objc private func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            segmentedControl.selectedSegmentIndex = 0
        }
        if (sender.direction == .right) {
            segmentedControl.selectedSegmentIndex = 1
        }
        
        city = getCityFromSegmentedControl()
        weather.getWeatherOf(city: city)
        
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let weatherDescription = weatherDescription,
              let date = date,
              let iconName = iconName,
              let temp = temp,
              let tempMin = tempMin,
              let tempMax = tempMax,
              let sunrise = sunrise,
              let sunset = sunset,
              let cell = tableView
                .dequeueReusableCell(withIdentifier: "WeatherCell")
                as? WeatherCell
        else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "WaitingCell"
            ) else {
                return ViewHelper.getEmptyCell()
            }
            return cell
        }
        
        cell.weatherDescription = weatherDescription
        cell.date = date
        cell.iconName = iconName
        cell.temp = temp
        cell.tempMin = tempMin
        cell.tempMax = tempMax
        cell.sunrise = sunrise
        cell.sunset = sunset
        
        cell.configureValues()
        
        return cell
    }
}
