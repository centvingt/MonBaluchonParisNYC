//
//  CurrencyViewController.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 01/06/2021.
//

import UIKit

class CurrencyViewController: UITableViewController {
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    
    private var currencyRate = CurrencyConversion()
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currencyRateDataIsSet(_:)),
            name: Notification.Name.currencyRateData,
            object: nil
        )
        city = getCityFromSegmentedControl()
    }
    override func viewWillAppear(_ animated: Bool) {
        currencyRate.getRate()
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
    
    @IBAction func segmentedChanged(_ sender: Any) {
        city = getCityFromSegmentedControl()
        tableView.reloadData()
    }
    
    private func getCityFromSegmentedControl() -> City {
        return segmentedControl.selectedSegmentIndex == 0 ? .paris : .nyc
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RateCell",
            for: indexPath
        ) as? CurrencyRateCell,
        let euroToUSDRate = euroToUSDRate,
        let usdToEuroRate = usdToEuroRate,
        let rateDate = rateDate,
        let city = city
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WaitingCell") else {
                let cell = UITableViewCell()
                cell.contentView.backgroundColor = UIColor.bpnRoseVille
                return cell
            }
            return cell
        }
        
        let rate = city == .paris ? euroToUSDRate : usdToEuroRate
        
        cell.configure(
            city: city,
            rate: rate,
            rateDate: rateDate
        )
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

