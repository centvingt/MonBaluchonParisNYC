//
//  TranslationViewController.swift
//  LeBaluchon
//
//  Created by Vincent Caronnet on 23/05/2021.
//

import UIKit

class TranslationViewController: UITableViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private var city: City?
    
    private var translation = Translation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("TranslationViewController ~> viewDidLoad")
        TranslationService.shared.getTranslation(
            of: "traduction",
            from: .fr,
            to: .en) { error, string in
            if let error = error { print(error) }
            if let string = string { print(string) }
        }
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
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
    
    // MARK: - Swipe handler
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
        return cell
    }
}
