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
        // #warning Incomplete implementation,  return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let _ = euroToUSDRate,
              let _ = usdToEuroRate,
              let _ = rateDate,
              let _ = city
        else { return 1 }
        return 3
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
        case 1, 2:
            return getConversionCell()
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
    private func getConversionCell() -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ConversionCell"
        ) as? CurrencyConversionCell else {
            return getEmptyCell()
        }
        cell.delegate = self
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension CurrencyViewController: CurrencyConversionCellDelegate {
    func processInput(_ cell: CurrencyConversionCell, input: String) {
        print("CurrencyViewController~>", input)
    }
}
