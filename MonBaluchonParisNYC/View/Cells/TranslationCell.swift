//
//  TranslationCell.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 29/06/2021.
//

import UIKit

class TranslationCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var outputActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var ioContainer: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var translateButton: UIButton!
    
    var delegate: TranslationCellDelegate?
    
    var inputLanguage = TranslationLanguage.en
    var titleText: String {
        switch inputLanguage {
        case .en:
            return "Anglais / français"
        case .fr:
            return "Français / anglais"
        }
    }
    var inputText = ""
    var outputText = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        inputTextView.delegate = self
        configure()
        configureIOValues()
    }

    // MARK: - Configuration
    
    func configure() {
        title.text = titleText
        
        let bpnBleuVille = UIColor.bpnBleuVille.cgColor
        let bpnRoseVille = UIColor.bpnRoseVille.cgColor
        
        ViewHelper.setRoundedAndShadowFor(view: mainContainer)
        ViewHelper.setRoundedAndShadowFor(view: titleContainer)
        ViewHelper.setRoundedAndShadowFor(view: ioContainer)
        
        ViewHelper.setRoundedAndBorderFor(
            view: outputTextView,
            with: bpnBleuVille
        )
        ViewHelper.setRoundedAndBorderFor(
            view: inputTextView,
            with: bpnRoseVille
        )
        
        ViewHelper.setRoundedAndBorderFor(
            view: deleteButton,
            with: bpnRoseVille
        )
        ViewHelper.setRoundedAndBorderFor(
            view: translateButton,
            with: bpnRoseVille
        )
    }
    
    func configureIOValues() {
        title.text = titleText
        inputTextView.text = inputText
        outputTextView.text = outputText
    }
    
    // MARK: - IB Actions
    
    @IBAction func deleteButtonDidPressed(_ sender: UIButton) {
        inputTextView.text = ""
    }
    @IBAction func translateButtonDidPressed(_ sender: UIButton) {
        delegate?.translateInput(value: inputTextView.text, of: self)
    }
}

extension TranslationCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputTextView.backgroundColor = .bpnRoseVille
        inputTextView.textColor = .bpnBleuGoudron
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        inputTextView.backgroundColor = .bpnBleuGoudron
        inputTextView.textColor = .bpnRoseVille
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let shouldChangeTextOfInput = delegate?
                .shouldChangeTextOfInput(
                    textView: textView,
                    range: range,
                    text: text
                ) else {
            print("TranslationCell ~> textView(shouldChangeTextIn) ~> CELL HAS NO DELEGATE!")
            return false
        }
        return shouldChangeTextOfInput
    }
}

protocol TranslationCellDelegate {
    func translateInput(value: String, of cell: TranslationCell)
    func shouldChangeTextOfInput(
        textView: UITextView,
        range: NSRange,
        text: String
    ) -> Bool
}
