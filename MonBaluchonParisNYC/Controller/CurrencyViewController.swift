//
//  CurrencyViewController.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 01/06/2021.
//

import UIKit

class CurrencyViewController: UITableViewController {
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    
    private var currency = Currency()
    private var euroToUSDRate: String?
    private var usdToEuroRate: String?
    private var rateDate: String?
    private var city: City?
    
    private var usdToEuroInput = "0 $"
    private var euroToUSDInput = "0 €"
    private var vatInput = "0 $"
    private var tip15Input = "0 $"
    private var tip20Input = "0 $"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
        guard let euroToUSDRate = notification.userInfo?["euroToUSDRate"] as? String,
              let usdToEuroRate = notification.userInfo?["usdToEuroRate"] as? String,
              let rateDate = notification.userInfo?["rateDate"] as? String
        else { return }
        self.euroToUSDRate = euroToUSDRate
        self.usdToEuroRate = usdToEuroRate
        self.rateDate = rateDate
        tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = euroToUSDRate,
              let _ = usdToEuroRate,
              let _ = rateDate,
              let _ = city
        else { return 1 }
        return city == .paris ? 2 : 5
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
            return getCalculationCell(calculation: .tip15)
        case 4:
            return getCalculationCell(calculation: .tip20)
        default:
            return getEmptyCell()
        }
    }
    
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
        cell.delegate = self
        cell.calculation = calculation
        cell.inputText = getInputText(from: calculation)
        cell.configure()
        return cell
    }
    private func getInputText(from calculation: CurrencyCalculation) -> String {
        switch calculation {
        case .usdToEuro:
            return usdToEuroInput
        case .euroToUSD:
            return usdToEuroInput
        case .vat:
            return vatInput
        case .tip15:
            return tip15Input
        case .tip20:
            return tip15Input
        }
    }
}
extension CurrencyViewController: CurrencyCalculationCellDelegate {
    func processInput(
        for cell: CurrencyCalculationCell,
        calculation: CurrencyCalculation,
        input: String
    ) {
        let newInput = currency.processInput(
            input: input,
            for: calculation
        )
        cell.inputText = newInput
        cell.configure()
    }
}
