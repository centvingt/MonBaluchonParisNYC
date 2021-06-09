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
    @IBOutlet weak var outputTextFieldTip20: UITextField!
    @IBOutlet weak var outputTextFieldTip15: UITextField!
    @IBOutlet weak var outputTip15StackView: UIStackView!
    @IBOutlet weak var outputTip20StackView: UIStackView!
    @IBOutlet weak var outputStackView: UIStackView!
    
    var delegate: CurrencyCalculationCellDelegate?
    var calculation = CurrencyCalculation.usdToEuro
    var titleText: String {
        switch calculation {
        case .usdToEuro:
            return "Conversion $/€"
        case .euroToUSD:
            return "Conversion €/$"
        case .vat:
            return "TVA à 8,875 %"
        case .tip:
            return "Calcul de pourboire"
        }
    }
    var inputText = "0 $"
    var outputText = "0 $"
    var outputTip15Text = "0 $"
    var outputTip20Text = "0 $"

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        inputTextField.delegate = self
        configureUI()
        configureTextFieldValues()
    }
    
    @IBAction func inputButtonDidPressed(_ sender: UIButton) {
        inputTextField.becomeFirstResponder()
    }
    @IBAction func inputTextFieldChanged(_ sender: Any) {
        guard let input = inputTextField.text else { return }
        delegate?.processInput(for: self, input: input)
    }
    @IBAction func deleteButtonDidPressed(_ sender: UIButton) {
        delegate?.deleteTextFieldText(for: self)
    }
    
    func configureUI() {
        title.text = titleText
        
        let bpnBleuVille = UIColor.bpnBleuVille.cgColor
        
        setRoundedAndShadowFor(view: mainContainer)
        setRoundedAndShadowFor(view: titleContainer)
        setRoundedAndShadowFor(view: textFieldsContainer)
        
        if calculation == .tip {
            setRoundedAndBorderFor(
                view: outputTextFieldTip15,
                with: bpnBleuVille
            )
            
            setRoundedAndBorderFor(
                view: outputTextFieldTip20,
                with: bpnBleuVille
            )
            
            outputStackView.isHidden = true
            
            outputTip15StackView.isHidden = false
            outputTip20StackView.isHidden = false
        } else {
            setRoundedAndBorderFor(
                view: outputTextField,
                with: bpnBleuVille
            )
            outputTip15StackView.isHidden = true
            outputTip20StackView.isHidden = true
        }
        
        setRoundedAndBorderFor(
            view: inputTextField,
            with: UIColor.bpnRoseVille.cgColor
        )
    }
    func configureTextFieldValues() {
        inputTextField.text = inputText
        setInputCursorPosition()
        
        if calculation == .tip {
            outputTextFieldTip15.text = outputTip15Text
            outputTextFieldTip20.text = outputTip20Text
        } else {
            outputTextField.text = outputText
        }
    }
}

extension CurrencyCalculationCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .bpnRoseVille
        textField.textColor = .bpnBleuGoudron
        setInputCursorPosition()
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.backgroundColor = .bpnBleuGoudron
        textField.textColor = .bpnRoseVille
    }
    
    private func setInputCursorPosition() {
        if let newPosition = inputTextField.position(
            from: inputTextField.endOfDocument,
            offset: -2
        ) {
            inputTextField.selectedTextRange = inputTextField.textRange(
                from: newPosition,
                to: newPosition
            )
        }
    }
}

protocol CurrencyCalculationCellDelegate {
    func processInput(
        for cell: CurrencyCalculationCell,
        input: String
    )
    func deleteTextFieldText(
        for cell: CurrencyCalculationCell
    )
}

