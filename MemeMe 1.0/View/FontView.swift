//
//  FontView.swift
//  MemeMe 1.0
//
//  Created by Saeed Khader on 02/11/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import Foundation
import UIKit

extension MemeEditorViewController {
    
    class FontView: UIStackView {
        
        var bottomLayout: NSLayoutConstraint?
        var activeTextField: UITextField!
        
        let fontOne: UIButton = {
            var button = UIButton()
            button.addTarget(self, action: #selector(fontOneChosen), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        let fontTwo: UIButton = {
            var button = UIButton()
            button.addTarget(self, action: #selector(fontTowChosen), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        let fontThree: UIButton = {
            var button = UIButton()
            button.addTarget(self, action: #selector(fontThreeChosen), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        let fontFour: UIButton = {
            var button = UIButton()
            button.addTarget(self, action: #selector(fontFourChosen), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        func setUp() {
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2536654538)
            self.axis = .horizontal
            self.spacing = 8
            self.distribution = .fillEqually
            self.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
            self.isLayoutMarginsRelativeArrangement = true
            
            setUpButtonStyle(button: fontOne, title: "Impact", font: UIFont(name: "Impact", size: 18)!)
            
            setUpButtonStyle(button: fontTwo, title: "Didot", font: UIFont(name: "Didot-Bold", size: 19)!)
            setUpButtonStyle(button: fontThree, title: "Noteworthy", font: UIFont(name: "Noteworthy-Bold", size: 17)!)
            setUpButtonStyle(button: fontFour, title: "Snell ", font: UIFont(name: "SnellRoundhand-Black", size: 21)!)
            
            self.addArrangedSubview(fontOne)
            self.addArrangedSubview(fontTwo)
            self.addArrangedSubview(fontThree)
            self.addArrangedSubview(fontFour)
        }
        
        func setUpLayout() {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor, constant: -10).isActive = true
            self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: 10).isActive = true
            self.heightAnchor.constraint(equalToConstant: 47).isActive = true
            
            bottomLayout = self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: 0)
            bottomLayout?.isActive = true
            
        }
        
        func setUpButtonStyle(button: UIButton, title: String, font: UIFont){
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.7937592864, green: 0.807882607, blue: 0.83379215, alpha: 1)
            button.titleLabel?.font = font
            button.titleLabel?.textAlignment = .center
            button.layer.cornerRadius = 5
            let widthContraints =  NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 39)
            NSLayoutConstraint.activate([widthContraints])
        }

        func checkFont() {
            switch activeTextField.font?.fontName {
            case "Impact":
                setChosenFontButtonStyle(button: fontOne)
            case "Didot-Bold":
                setChosenFontButtonStyle(button: fontTwo)
            case "Noteworthy-Bold":
                setChosenFontButtonStyle(button: fontThree)
            case "SnellRoundhand-Black":
                setChosenFontButtonStyle(button: fontFour)
            default:
                return
            }

        }

        func setChosenFontButtonStyle(button: UIButton){
            resetFontButtonStyle(button: fontOne)
            resetFontButtonStyle(button: fontTwo)
            resetFontButtonStyle(button: fontThree)
            resetFontButtonStyle(button: fontFour)
            
            button.backgroundColor = #colorLiteral(red: 0.6267091632, green: 0.6549741626, blue: 0.7024829984, alpha: 1)
            
        }

        func resetFontButtonStyle(button: UIButton) {
            button.backgroundColor = #colorLiteral(red: 0.7937592864, green: 0.807882607, blue: 0.83379215, alpha: 1)
        }
    }
    
    @objc func fontOneChosen() {
        fontView.activeTextField.font = UIFont(name: "Impact", size: 40)
        fontView.activeTextField.defaultTextAttributes[NSAttributedString.Key.strokeWidth] = -5
        fontView.setChosenFontButtonStyle(button: fontView.fontOne)
    }

    @objc func fontTowChosen() {
        fontView.activeTextField.font = UIFont(name: "Didot-Bold", size: 40)
        fontView.activeTextField.defaultTextAttributes[NSAttributedString.Key.strokeWidth] = -1
        fontView.setChosenFontButtonStyle(button: fontView.fontTwo)
    }

    @objc func fontThreeChosen() {
        fontView.activeTextField.font = UIFont(name: "Noteworthy-Bold", size: 40)
        fontView.activeTextField.defaultTextAttributes[NSAttributedString.Key.strokeWidth] = -2
        fontView.setChosenFontButtonStyle(button: fontView.fontThree)
    }

    @objc func fontFourChosen() {
        fontView.activeTextField.font = UIFont(name: "SnellRoundhand-Black", size: 40)
        fontView.activeTextField.defaultTextAttributes[NSAttributedString.Key.strokeWidth] = -1
        fontView.setChosenFontButtonStyle(button: fontView.fontFour)
    }
}



