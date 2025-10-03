//
//  CollectCell.swift
//  UIKitProject
//
//  Created by Rath! on 3/10/25.
//

import UIKit

class NormalFruitCell: UICollectionViewCell {
    static let identifier = "NormalFruitCell"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        label.frame = contentView.bounds
        label.textAlignment = .center
        contentView.addSubview(label)
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with fruit: Fruit) {
        label.text = "\(fruit.name) - $\(fruit.price)"
    }
}

class SpecialFruitCell: UICollectionViewCell {
    static let identifier = "SpecialFruitCell"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .yellow
        label.frame = contentView.bounds
        label.textAlignment = .center
        contentView.addSubview(label)
        contentView.layer.borderColor = UIColor.red.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with fruit: Fruit) {
        label.text = "\(fruit.name) - $\(fruit.price) 🌟"
    }
}
