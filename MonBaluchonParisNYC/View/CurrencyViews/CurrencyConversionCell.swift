//
//  CurrencyConversionCell.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 03/06/2021.
//

import UIKit

class CurrencyConversionCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var textFieldsContainer: UIView!
    @IBOutlet weak var outputTextField: UITextField!
    @IBOutlet weak var inputTextField: UITextField!
    
    var delegate: CurrencyConversionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setRoundedAndShadowFor(mainContainer)
        setRoundedAndShadowFor(titleContainer)
        setRoundedAndShadowFor(textFieldsContainer)
        
        outputTextField.layer.borderWidth = 1
        outputTextField.layer.borderColor = UIColor.bpnBleuVille.cgColor
        outputTextField.layer.cornerRadius = getBPNRadius()
        
        inputTextField.layer.borderWidth = 1
        inputTextField.layer.borderColor = UIColor.bpnRoseVille.cgColor
        inputTextField.layer.cornerRadius = getBPNRadius()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func inputTextFieldChanged(_ sender: Any) {
        guard let input = inputTextField.text else { return }
        delegate?.processInput(self, input: input)
    }
    func configure(
    ) {
        inputTextField.delegate = self
    }
}

extension CurrencyConversionCell: UITextFieldDelegate {
    
}

protocol CurrencyConversionCellDelegate {
    func processInput(_ cell: CurrencyConversionCell, input: String)
}
