//
//  TableCell.swift
//  UIKitProject
//
//  Created by Rath! on 3/10/25.
//

import Foundation
import UIKit


class NormalFruitTableCell: UITableViewCell {
    static let identifier = "NormalFruitCell"
    
    func configure(with fruit: Fruit) {
        textLabel?.text = "\(fruit.name) - $\(fruit.price)"
        backgroundColor = .white
    }
}

class SpecialFruitTableCell: UITableViewCell {
    static let identifier = "SpecialFruitCell"
    
    func configure(with fruit: Fruit) {
        textLabel?.text = "\(fruit.name) - $\(fruit.price) 🌟"
        backgroundColor = .yellow
    }
}
