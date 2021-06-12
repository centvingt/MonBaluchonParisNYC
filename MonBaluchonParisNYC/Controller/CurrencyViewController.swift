//
//  CurrencyViewController.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 01/06/2021.
//

import UIKit

class CurrencyViewController: UITableViewController {
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    
    private var city: City?
    
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
        registerForKeyboardNotifications()
        city = getCityFromSegmentedControl()
    }
    override func viewWillAppear(_ animated: Bool) {
        currency.getRate()
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
        
//        tableView.reloadData()
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
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
        tableView.contentInset.bottom = keyboardFrame.size.height
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
              let _ = rateDate,
              let _ = city
        else { return 1 }
        return city == .paris ? 2 : 4
    }
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let euroToUSDRate = euroToUSDRate,
              let usdToEuroRate = usdToEuroRate,
              let rateDate = rateDate,
              let city = city
        else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "WaitingCell"
            ) else {
                return getEmptyCell()
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
            return getEmptyCell()
        }
    }
    
    // MARK: - Table view cells
    
    private func getEmptyCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = UIColor.bpnRoseVille
        return cell
    }
    private func getRateCell(
        euroToUSDRate: String,
        usdToEuroRate: String,
        rateDate: String,
        city: City
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RateCell"
        ) as? CurrencyRateCell else {
            return getEmptyCell()
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
            return getEmptyCell()
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
            print("CurrencyViewController ~> paste ~> ERREUR")
            
            return
        }
        
        setIOValues(of: calculation, with: newIOValues)
        
        configureData(of: cell)
        
        cell.configureTextFieldValues()
        
        haptic.runSuccess()
        
        
    }
    
    
}
