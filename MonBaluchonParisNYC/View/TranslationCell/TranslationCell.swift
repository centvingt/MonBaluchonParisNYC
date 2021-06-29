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
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var ioContainer: UIView!
    
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
        configureUI()
        configureIOValues()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureUI() {
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
    }
    
    func configureIOValues() {
        inputTextView.text = inputText
        outputTextView.text = outputText
    }
}

extension TranslationCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("begin")
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print("end")
    }
}
