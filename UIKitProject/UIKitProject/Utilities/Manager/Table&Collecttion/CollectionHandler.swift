//
//  CollectionHandler.swift
//  UIKitProject
//
//  Created by Rath! on 3/10/25.
//

import Foundation
import UIKit

struct CollectionSection<T> {
    let title: String?
    let items: [T]
}


class CollectionHandler<T: Codable>: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var sections: [CollectionSection<T>]
    
    // Cell closures
    var configureCell: ((UICollectionViewCell, T, IndexPath) -> Void)?
    var cellIdentifierForItem: ((T, IndexPath) -> String)?
    var didSelectItemAt: ((T) -> Void)?
    
    // Header/Footer closures
    var viewForHeaderInSection: ((CollectionSection<T>, Int) -> UICollectionReusableView?)?
    var viewForFooterInSection: ((CollectionSection<T>, Int) -> UICollectionReusableView?)?
    
    init(sections: [CollectionSection<T>]) {
        self.sections = sections
    }
    
    // MARK: - DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        let identifier = cellIdentifierForItem?(item, indexPath) ?? "cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        configureCell?(cell, item, indexPath)
        return cell
    }
    
    // MARK: - Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        didSelectItemAt?(item)
    }
    
    // MARK: - Flow Layout (Headers/Footers)
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader,
           let view = viewForHeaderInSection?(sections[indexPath.section], indexPath.section) {
            return view
        } else if kind == UICollectionView.elementKindSectionFooter,
                  let view = viewForFooterInSection?(sections[indexPath.section], indexPath.section) {
            return view
        }
        
        return UICollectionReusableView()
    }
    
    // Optional: size for header/footer
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewForHeaderInSection != nil ? CGSize(width: collectionView.frame.width, height: 50) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return viewForFooterInSection != nil ? CGSize(width: collectionView.frame.width, height: 30) : .zero
    }
    
}

