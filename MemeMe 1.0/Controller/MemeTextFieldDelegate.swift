//
//  MemeTextFieldDelegate.swift
//  MemeMe 1.0
//
//  Created by Saeed Khader on 26/09/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation
import UIKit

extension MemeEditorViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if let fontView = fontView {
            fontView.removeFromSuperview()
        }
        fontView = FontView()
        fontView.activeTextField = textField
        view.addSubview(fontView)
        fontView.setUp()
        fontView.setUpLayout()
        fontView.isHidden = false
        fontView.checkFont()
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        fontView.isHidden = true
        activeTextField = nil
    }
    
}
