//
//  DisplayCollectVC.swift
//  UIKitProject
//
//  Created by Rath! on 3/10/25.
//

import UIKit

class DisplayCollectVC: UIViewController {
    
    var collectionHandler: CollectionHandler<Fruit>!
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
        layout.itemSize = CGSize(width: (view.frame.width - 48) / 2, height: 80)
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 50)
        layout.footerReferenceSize = CGSize(width: view.frame.width, height: 30)
        
        let cv = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        cv.backgroundColor = .cyan
        cv.register(NormalFruitCell.self, forCellWithReuseIdentifier: NormalFruitCell.identifier)
        cv.register(SpecialFruitCell.self, forCellWithReuseIdentifier: SpecialFruitCell.identifier)
        
        cv.register(HeaderCollectiontView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: HeaderCollectiontView.identifier)
        cv.register(FooterCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: FooterCollectionView.identifier)
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        setupCollectionHandler()
    }
    
    func setupCollectionHandler() {
        let normalFruits = [
            Fruit(name: "Apple", price: 1.2, isSpecial: false),
            Fruit(name: "Cherry", price: 2.0, isSpecial: false)
        ]
        let specialFruits = [
            Fruit(name: "Banana", price: 0.5, isSpecial: true),
            Fruit(name: "Durian", price: 5.0, isSpecial: true)
        ]
        
        let sections = [
            CollectionSection(title: "Normal Fruits", items: normalFruits),
            CollectionSection(title: "Special Fruits", items: specialFruits)
        ]
        
        collectionHandler = CollectionHandler(sections: sections)
        collectionView.dataSource = collectionHandler
        collectionView.delegate = collectionHandler
        
        // Cells
        collectionHandler.cellIdentifierForItem = { item, indexPath in
            return item.isSpecial ? SpecialFruitCell.identifier : NormalFruitCell.identifier
        }
        
        collectionHandler.configureCell = { cell, item, indexPath in
            if let normalCell = cell as? NormalFruitCell {
                normalCell.configure(with: item)
            } else if let specialCell = cell as? SpecialFruitCell {
                specialCell.configure(with: item)
            }
        }
        
        // Selection
        collectionHandler.didSelectItemAt = { item in
            print("Selected: \(item.name)")
        }
        
        // Headers
        collectionHandler.viewForHeaderInSection = { section, _ in
            let header = self.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: HeaderCollectiontView.identifier,
                for: IndexPath(item: 0, section: 0)
            ) as! HeaderCollectiontView
            header.label.text = section.title
            return header
        }
        
        // Footers
        collectionHandler.viewForFooterInSection = { section, _ in
            let footer = self.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: FooterCollectionView.identifier,
                for: IndexPath(item: 0, section: 0)
            ) as! FooterCollectionView
            footer.label.text = "Total items: \(section.items.count)"
            return footer
        }
    }
}


class HeaderCollectiontView: UICollectionReusableView {
    static let identifier = "HeaderView"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        label.frame = bounds
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

class FooterCollectionView: UICollectionReusableView {
    static let identifier = "FooterCollectionView"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .gray
        label.frame = bounds
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
