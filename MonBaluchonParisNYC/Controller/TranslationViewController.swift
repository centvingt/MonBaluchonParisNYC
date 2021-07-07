//
//  TranslationViewController.swift
//  LeBaluchon
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import UIKit

class TranslationViewController: UITableViewController {
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

    private var translation = Translation()
    
    private let haptic = Haptic()
    
    private var inputEnToFR = ""
    private var outputEnToFr = ""
    
    private var inputFrToEn = ""
    private var outputFrToEn = ""
    
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
    }
    override func viewWillAppear(_ animated: Bool) {
        setSegmentedControl()
    }
    
    // MARK: - Notifications
    func presentAlert(for bpnError: BPNError) {
        var title = ""
        var message = ""
        
        if bpnError == .internetConnection {
            title = "Pas de connection internet"
            message = "Activez votre connexion internet avant d’utiliser l’application."
        }
        if bpnError == .undefinedRequestError {
            title = "Erreur"
            message = "Une erreur indéterminée est survenue."
        }
        if bpnError == .translationRequestLimitExceeded {
            title = "Limite dépassée"
            message = "Vous ne pouvez pas effectuer plus de \(translation.maxRequestPerDay) traduction par jour, ré-essayez demain."
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
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
        tableView.contentInset.bottom = keyboardFrame.size.height - tabBarHeight
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset.bottom = 0
    }
    
    // MARK: - Actions
    
    @IBAction func segmentedChanged(_ sender: Any) {
        city = getCityFromSegmentedControl()
        
        tableView.reloadData()
    }
    private func getCityFromSegmentedControl() -> City {
        return segmentedControl.selectedSegmentIndex == 0 ? .paris : .nyc
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TranslationCell") as? TranslationCell else {
            return ViewHelper.getEmptyCell()
        }
        
        let inputLanguage = city.language.from
        
        cell.delegate = self
        
        cell.inputLanguage = inputLanguage
        
        switch inputLanguage {
        case .en:
            cell.inputText = inputEnToFR
            cell.outputText = outputEnToFr
        case .fr:
            cell.inputText = inputFrToEn
            cell.outputText = outputFrToEn
        }
        cell.configureIOValues()
        
        return cell
    }
}

extension TranslationViewController: TranslationCellDelegate {
    func shouldChangeTextOfInput(
        textView: UITextView, 
        range: NSRange, 
        text: String
    ) -> Bool {
        let newText = (textView.text as NSString)
            .replacingCharacters(in: range, with: text)
        
        guard newText.count < translation.maxCharacters else {
            haptic.runError()
            return false
        }
        
        return true
    }
    
    func translateInput(value: String, of cell: TranslationCell) {
        cell.outputActivityIndicator.startAnimating()
        cell.outputTextView.text = ""
        
        let from = city.language.from
        let to = city.language.to

        translation.getTranslation(
            of: value,
            from: from,
            to: to
        ) { bpnError, string in
            cell.outputActivityIndicator.stopAnimating()
            
            if let bpnError = bpnError {
                self.presentAlert(for: bpnError)
                return
            }
            
            guard let string = string else {
                // TODO: Présenter une alerte d’erreur indéfinie
                print("TranslationViewController ~> translateInput ~> getTranslation ~> STRING IS NIL")
                return
            }
            
            switch from {
            case .en:
                self.inputEnToFR = value
                self.outputEnToFr = string
            case .fr:
                self.inputFrToEn = value
                self.outputFrToEn = string
            }
            
            self.tableView.reloadData()
        }
    }
}
