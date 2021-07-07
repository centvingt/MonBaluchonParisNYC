//
//  CurrencyViewController.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 01/06/2021.
//

import UIKit

class CurrencyViewController: UITableViewController {
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
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
    
    private var currency = Currency()
    
    private var euroToUSDRate: String?
    private var usdToEuroRate: String?
    private var rateDate: String?
    
    private var usdToEuroIOValues = CurrencyIOValues(for: .usdToEuro)
    private var euroToUSDIOValues = CurrencyIOValues(for: .euroToUSD)
    private var vatIOValues = CurrencyIOValues(for: .vat)
    private var tipIOValues = CurrencyIOValues(for: .tip)
    
    private let haptic = Haptic()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForRateDataNotification()
        registerForErrorNotifications()
        registerForKeyboardNotifications()
        
//        city = getCityFromSegmentedControl()
        setSegmentedControl()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        if #available(iOS 13.0, *) {
            guard let font = UIFont(name: "SF Compact Rounded", size: 16.0) else {
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
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.bpnRoseVille as Any, .font: font], for: .selected)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        currency.getRate()
        setSegmentedControl()
    }
    
    // MARK: - Notifications
    
    private func registerForRateDataNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currencyRateDataIsSet(_:)),
            name: Notification.Name.currencyRateData,
            object: nil
        )
    }
    @objc private func currencyRateDataIsSet(_ notification: NSNotification) {
        guard let euroToUSDRate = notification
                .userInfo?["euroToUSDRate"] as? String,
              let usdToEuroRate = notification
                .userInfo?["usdToEuroRate"] as? String,
              let rateDate = notification
                .userInfo?["rateDate"] as? String,
              let usdToEuroIOValues = notification
                .userInfo?["usdToEuroIOValues"] as? CurrencyIOValues,
              let euroToUSDIOValues = notification
                .userInfo?["euroToUSDIOValues"] as? CurrencyIOValues,
              let vatIOValues = notification
                .userInfo?["vatIOValues"] as? CurrencyIOValues,
              let tipIOValues = notification
                .userInfo?["tipIOValues"] as? CurrencyIOValues
        else { return }
        
        self.euroToUSDRate = euroToUSDRate
        self.usdToEuroRate = usdToEuroRate
        self.rateDate = rateDate
        self.usdToEuroIOValues = usdToEuroIOValues
        self.euroToUSDIOValues = euroToUSDIOValues
        self.vatIOValues = vatIOValues
        self.tipIOValues = tipIOValues
        
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
        
        currency.removeUselessCommasFromInputs()
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
        guard let _ = euroToUSDRate,
              let _ = usdToEuroRate,
              let _ = rateDate
        else { return 1 }
        return city == .paris ? 2 : 4
    }
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let euroToUSDRate = euroToUSDRate,
              let usdToEuroRate = usdToEuroRate,
              let rateDate = rateDate
        else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "WaitingCell"
            ) else {
                return ViewHelper.getEmptyCell()
            }
            return cell
        }
        
        switch indexPath.row {
        case 0:
            return getRateCell(
                euroToUSDRate: euroToUSDRate,
                usdToEuroRate: usdToEuroRate,
                rateDate: rateDate,
                city: city
            )
        case 1:
            return getCalculationCell(
                calculation: city == .paris
                    ? .euroToUSD
                    : .usdToEuro
            )
        case 2:
            return getCalculationCell(calculation: .vat)
        case 3:
            return getCalculationCell(calculation: .tip)
        default:
            return ViewHelper.getEmptyCell()
        }
    }
    
    // MARK: - Table view cells
    
    private func getRateCell(
        euroToUSDRate: String,
        usdToEuroRate: String,
        rateDate: String,
        city: City
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RateCell"
        ) as? CurrencyRateCell else {
            return ViewHelper.getEmptyCell()
        }
        
        let rate = city == .paris ? euroToUSDRate : usdToEuroRate
        
        cell.configure(
            city: city,
            rate: rate,
            rateDate: rateDate
        )
        return cell
    }
    private func getCalculationCell(calculation: CurrencyCalculation) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CalculationCell"
        ) as? CurrencyCalculationCell else {
            return ViewHelper.getEmptyCell()
        }
        cell.calculation = calculation
        
        cell.delegate = self
        
        configureData(of: cell)
        
        cell.configureUI()
        cell.configureTextFieldValues()
        
        return cell
    }
    
    // MARK: - Helpers for CalculationCell
    
    private func getInputText(
        from calculation: CurrencyCalculation
    ) -> String {
        switch calculation {
        case .usdToEuro:
            return usdToEuroIOValues.input
        case .euroToUSD:
            return euroToUSDIOValues.input
        case .vat:
            return vatIOValues.input
        case .tip:
            return tipIOValues.input
        }
    }
    private func getOutpuText(
        from calculation: CurrencyCalculation
    ) -> [String] {
        switch calculation {
        case .usdToEuro:
            return usdToEuroIOValues.output
        case .euroToUSD:
            return euroToUSDIOValues.output
        case .vat:
            return vatIOValues.output
        case .tip:
            return tipIOValues.output
        }
    }
    private func configureData(of cell: CurrencyCalculationCell) {
        let calculation = cell.calculation
        
        cell.inputText = getInputText(from: calculation)
        
        if calculation == .tip {
            cell.outputTip15Text = getOutpuText(from: calculation)[0]
            cell.outputTip20Text = getOutpuText(from: calculation)[1]
        } else {
            cell.outputText = getOutpuText(from: calculation)[0]
        }
    }
    private func setIOValues(
        of calculation: CurrencyCalculation,
        with newIOValues: CurrencyIOValues
    ) {
        switch calculation {
        case .usdToEuro:
            usdToEuroIOValues = newIOValues
        case .euroToUSD:
            euroToUSDIOValues = newIOValues
        case .vat:
            vatIOValues = newIOValues
        case .tip:
            tipIOValues = newIOValues
        }
    }
}
extension CurrencyViewController: CurrencyCalculationCellDelegate {
    func deleteTextFieldText(for cell: CurrencyCalculationCell) {
        let calculation = cell.calculation
        
        let newIOValues = currency.deleteInput(for: cell.calculation)
        
        setIOValues(of: calculation, with: newIOValues)
        
        configureData(of: cell)
        
        cell.configureTextFieldValues()
        
        haptic.runWarning()
        
    }
    
    func processInput(
        for cell: CurrencyCalculationCell,
        input: String
    ) {
        let calculation = cell.calculation
        
        let newIOValues = currency.processInput(
            input: input,
            for: calculation
        )
        
        setIOValues(of: calculation, with: newIOValues)
        
        configureData(of: cell)
        
        cell.configureTextFieldValues()
        
        haptic.runLight()
    }
    
    func copy(
        value: String
    ) {
        currency.copy(value: value)
        haptic.runSuccess()
    }
    func paste(in cell: CurrencyCalculationCell) {
        let calculation = cell.calculation
        
        guard let newIOValues = currency.pasteInInput(
            of: calculation
        ) else {
            haptic.runError()
            
            // TODO: Afficher une alerte
            NotificationCenter.default.post(Notification(name: .errorBadPasteboardValue))
            
            return
        }
        
        setIOValues(of: calculation, with: newIOValues)
        
        configureData(of: cell)
        
        cell.configureTextFieldValues()
        
        haptic.runSuccess()
    }
}
