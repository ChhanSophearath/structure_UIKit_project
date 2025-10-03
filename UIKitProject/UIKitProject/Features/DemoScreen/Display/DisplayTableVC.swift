//
//  DisplayTableVC.swift
//  UIKitProject
//
//  Created by Rath! on 3/10/25.
//

import UIKit

class DisplayTableVC: UIViewController {
    
    var tableHandler: TableHandler<Fruit>!
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: view.bounds, style: .grouped)
        table.register(NormalFruitTableCell.self, forCellReuseIdentifier: NormalFruitTableCell.identifier)
        table.register(SpecialFruitTableCell.self, forCellReuseIdentifier: SpecialFruitTableCell.identifier)
        table.backgroundColor = .cyan
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableViewHandler()
    }
    
    func tableViewHandler() {
        // Section 0: Normal fruits
        let normalFruits = [
            Fruit(name: "Apple", price: 1.2, isSpecial: false),
            Fruit(name: "Cherry", price: 2.0, isSpecial: false)
        ]
        
        // Section 1: Special fruits
        let specialFruits = [
            Fruit(name: "Banana", price: 0.5, isSpecial: true),
            Fruit(name: "Durian", price: 5.0, isSpecial: true)
        ]
        
        // Create sections
        let sections = [
            TableSection(title: "Normal Fruits", items: normalFruits),
            TableSection(title: "Special Fruits", items: specialFruits)
        ]
        
        // Initialize handler
        tableHandler = TableHandler(sections: sections)
        tableView.dataSource = tableHandler
        tableView.delegate = tableHandler
        
        // Return different cell identifiers per section
        tableHandler.cellIdentifierForItem = { item, indexPath in
            return indexPath.section == 0 ? NormalFruitTableCell.identifier : SpecialFruitTableCell.identifier
        }
        
        // Configure cells
        tableHandler.configureCell = { cell, item, indexPath in
            if indexPath.section == 0, let normalCell = cell as? NormalFruitTableCell {
                normalCell.configure(with: item)
            } else if indexPath.section == 1, let specialCell = cell as? SpecialFruitTableCell {
                specialCell.configure(with: item)
            }
        }
        
        // Handle selection per section
        tableHandler.didSelectRowAt = { item in
            if normalFruits.contains(where: { $0.name == item.name }) {
                print("Normal fruit selected: \(item.name)")
            } else {
                print("Special fruit selected: \(item.name)")
            }
        }
        
        tableHandler.viewForHeaderInSection = { section, index in
            let headerView = UIView()
            headerView.backgroundColor = .lightGray
            
            let label = UILabel()
            label.text = section.title
            label.font = .boldSystemFont(ofSize: 16)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            
            headerView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            ])
            
            return headerView
        }
        
        
        tableHandler.viewForFooterInSection = { section, index in
            let headerView = UIView()
            headerView.backgroundColor = .lightGray
            
            let label = UILabel()
            label.text = section.title
            label.font = .boldSystemFont(ofSize: 12)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            
            headerView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            ])
            
            return headerView
        }
    }
}
