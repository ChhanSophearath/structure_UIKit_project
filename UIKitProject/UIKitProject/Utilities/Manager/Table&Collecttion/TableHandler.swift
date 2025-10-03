//
//  TableViewManager.swift
//  UIKitProject
//
//  Created by Rath! on 3/10/25.
//

import Foundation
import UIKit



// Section model
struct TableSection<T> {
    let title: String?
    let items: [T]
}

// TableHandler class (supports sections)
class TableHandler<T: Codable>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var sections: [TableSection<T>]
    
    var configureCell: ((UITableViewCell, T, IndexPath) -> Void)?
    var cellIdentifierForItem: ((T, IndexPath) -> String)?
    var didSelectRowAt: ((T) -> Void)?
    var willDisplayCell: ((UITableViewCell, T, IndexPath) -> Void)?
    
    var viewForHeaderInSection: ((TableSection<T>, Int) -> UIView?)?
    var viewForFooterInSection: ((TableSection<T>, Int) -> UIView?)?
    
    init(sections: [TableSection<T>]) {
        self.sections = sections
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        let identifier = cellIdentifierForItem?(item, indexPath) ?? "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        configureCell?(cell, item, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        didSelectRowAt?(item)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        willDisplayCell?(cell, item, indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewForHeaderInSection?(sections[section], section)
    }
      
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return viewForFooterInSection?(sections[section], section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewForHeaderInSection == nil ? 0 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewForFooterInSection == nil ? 0 : UITableView.automaticDimension
    }
    
}
