//
//  TextFieldPhone.swift
//  UIKitProject
//
//  Created by Rath! on 6/3/25.
//

import UIKit


class BaseUITextFieldPhone: UITextField, UITextFieldDelegate {
    
    var textDidChange: ((_ : String) -> ())?
    
    private var strPrefix: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        self.backgroundColor = .clear
        self.font = UIFont.boldSystemFont(ofSize: 17)
        self.borderStyle = .none
        self.placeholder = "XXX XXX XXX"
        self.keyboardType = .numberPad
        self.tintColor = .orange
        self.delegate = self  // Ensure delegate is set to self
        self.padding(left: 15, right: 15)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print("shouldChangeCharactersIn")
        
        guard let text = textField.text else { return false }
        
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        
        let prefix6Digit = [
            // CellCard
            "11", "12", "14", "17", "61", "77", "78", "85", "89", "92", "95", "99",
            // Smart
            "10", "15", "16", "69", "70", "81", "86", "87", "93", "98",
            // Metfone
            "60", "66", "67", "68", "90",
            // qb
            "13", "80", "83", "84",
            // Excell
            "18"
        ]
        
        // Clean up the string by removing non-numeric characters
        var cleanString = newString.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // If the string starts with "0", remove it
        if cleanString.first == "0" {
            cleanString = String(cleanString.dropFirst())
        }
        
        // Get the prefix (first 2 digits) to decide the format
        let strPrefix = String(cleanString.prefix(2))
        
        // Format the phone number based on the prefix
        if prefix6Digit.contains(strPrefix) {
            // Apply format for prefixes that are in the list
            textField.text = formatter(mask: "XX XXX XXX", phoneNumber: cleanString)
        } else {
            // Apply format for other prefixes
            textField.text = formatter(mask: "XX XXX XXXX", phoneNumber: cleanString)
        }
        
        return false  // Prevent default text change
    }
    
    private func formatter(mask: String, phoneNumber: String) -> String {
        
        let number = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result:String = ""
        var index = number.startIndex
        
        for character in mask where index < number.endIndex {
            if character == "X"{
                result.append(number[index])
                index = number.index(after: index)
            }else {
                result.append(character)
            }
        }
        
        return result
    }
}







extension UITextField {
    
    /// Apply a mask formatter to the textfield's current text
    /// - Parameters:
    ///   - mask: The format mask (use "X" as placeholder for digits)
    ///   - replacement: Optional string to format (default: current text in textfield)
    func applyFormat(mask: String, replacement: String? = nil) {
        let input = replacement ?? self.text ?? ""
        
        // Remove all non-numeric characters
        let number = input.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression
        )
        
        var result = ""
        var index = number.startIndex
        
        // Loop through mask
        for char in mask where index < number.endIndex {
            if char == "X" {
                result.append(number[index])
                index = number.index(after: index)
            } else {
                result.append(char)
            }
        }
        
        self.text = result
    }
}

