//
//  PhoneTextFieldVC.swift
//  UIKitProject
//
//  Created by Rath! on 3/10/25.
//

import Foundation
import UIKit

class PhoneTextFieldVC: BaseUIViewConroller {
    
    private  var nsButton = NSLayoutConstraint()
    
    lazy var phoneTextField: BaseUITextFieldPhone = {
        let textField = BaseUITextFieldPhone()
        textField.placeholder = "Enter phone number"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    
    lazy var btnButton: BaseUIButton = {
        let button = BaseUIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(didTappedDone), for: .touchUpInside)
        return button
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.dismissKeyboard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Phone TextField"
        setupPhoneNumberTextField()
        keyboradHandleer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        phoneTextField.becomeFirstResponder()
    }
    
    
    @objc private func didTappedDone(){
        print("didTappedDone")
    }
    
    private func keyboradHandleer(){
        
        keyboardManager.onKeyboardWillShow = { [weak self] keyboardHeight in
            guard let self = self else { return }
            self.nsButton.constant = keyboardHeight - 20
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardManager.onKeyboardWillHide = { [weak self] in
            guard let self = self else { return }
            self.nsButton.constant = .mainSpacingBottomButton
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setupPhoneNumberTextField() {
        // Create a UITextField programmatically
        view.addSubview(btnButton)
        view.addSubview(phoneTextField)
        
        // Set constraints for the phone number text field
        NSLayoutConstraint.activate([
            phoneTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            phoneTextField.widthAnchor.constraint(equalToConstant: 250),
            phoneTextField.heightAnchor.constraint(equalToConstant: 50),
            
            btnButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            btnButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
        ])
        
        nsButton = btnButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: .mainSpacingBottomButton)
        nsButton.isActive = true
    }
}
