//
//  DescriptionSendCell.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-16.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class DescriptionSendCell : SendCell {

    init(placeholder: String) {
        super.init()
        let attributes: [String: Any] = [
            NSForegroundColorAttributeName: UIColor.grayTextTint,
            NSFontAttributeName : placeholderFont
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        textField.delegate = self
        textField.textColor = .darkText
        textField.returnKeyType = .done
        setupViews()
    }


    var textFieldDidBeginEditing: (() -> Void)?
    var textFieldDidReturn: ((UITextField) -> Void)?
    var textFieldDidChange: ((String) -> Void)?
    var content: String? {
        didSet {
            textField.text = content
            textField.sendActions(for: .editingChanged)
            guard let count = content?.characters.count else { return }
            textField.font = count > 0 ? textFieldFont : placeholderFont
        }
    }

    private let placeholderFont = UIFont.customBody(size: 16.0)
    private let textFieldFont = UIFont.customBody(size: 20.0)
    let textField = UITextField()

    private func setupViews() {
        addSubview(textField)
        textField.constrain([
            textField.constraint(.leading, toView: self, constant: C.padding[2]),
            textField.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 30.0),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]) ])

        textField.addTarget(self, action: #selector(DescriptionSendCell.editingChanged(textField:)), for: .editingChanged)
    }

    @objc private func editingChanged(textField: UITextField) {
        guard let text = textField.text else { return }
        textFieldDidChange?(text)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DescriptionSendCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDidBeginEditing?()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let count = (textField.text ?? "").utf8.count + string.utf8.count
        if count > C.maxMemoLength {
            return false
        } else {
            return true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidReturn?(textField)
        return true
    }
}
