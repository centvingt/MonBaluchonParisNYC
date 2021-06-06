//
//  CurrencyCalculationCell.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 03/06/2021.
//

import UIKit

class CurrencyCalculationCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var textFieldsContainer: UIView!
    @IBOutlet weak var outputTextField: UITextField!
    @IBOutlet weak var inputTextField: UITextField!
    
    var delegate: CurrencyCalculationCellDelegate?
    var calculation = CurrencyCalculation.usdToEuro
    var titleText: String {
        switch calculation {
        case .usdToEuro:
            return "Conversion $/€"
        case .euroToUSD:
            return "Conversion €/$"
        case .vat:
            return "Calcul de la TVA à 8,875 %"
        case .tip15:
            return "Ajout de 15 % de pourboire"
        case .tip20:
            return "Ajout de 20 % de pourboire"
        }
    }
    var inputText = "0 $"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        configure()
        
    }
    
    @IBAction func inputButtonDidPressed(_ sender: UIButton) {
        inputTextField.becomeFirstResponder()
    }
    @IBAction func inputTextFieldChanged(_ sender: Any) {
        guard let input = inputTextField.text else { return }
        delegate?.processInput(for: self, calculation: calculation, input: input)
    }
    
    func configure() {
        title.text = titleText
        
        setRoundedAndShadowFor(view: mainContainer)
        setRoundedAndShadowFor(view: titleContainer)
        setRoundedAndShadowFor(view: textFieldsContainer)
        
        setRoundedAndBorderFor(view: outputTextField, with: UIColor.bpnBleuVille.cgColor)
        setRoundedAndBorderFor(view: inputTextField, with: UIColor.bpnRoseVille.cgColor)
        
        inputTextField.delegate = self
        
        inputTextField.text = inputText
        setCursorPosition()
    }
}

extension CurrencyCalculationCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .bpnRoseVille
        textField.textColor = .bpnBleuGoudron
        setCursorPosition()
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.backgroundColor = .bpnBleuGoudron
        textField.textColor = .bpnRoseVille
    }
    
    private func setCursorPosition() {
        if let newPosition = inputTextField.position(from: inputTextField.endOfDocument, offset: -2) {
            inputTextField.selectedTextRange = inputTextField.textRange(from: newPosition, to: newPosition)
        }
    }
}

protocol CurrencyCalculationCellDelegate {
    func processInput(
        for cell: CurrencyCalculationCell,
        calculation: CurrencyCalculation,
        input: String
    )
}

