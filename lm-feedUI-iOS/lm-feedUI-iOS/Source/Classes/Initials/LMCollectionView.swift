//
//  LMCollectionView.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 05/01/24.
//

import UIKit

extension UICollectionView {
    func registerCell(type: UICollectionViewCell.Type) {
        let className = String(describing: type)
        register(type, forCellWithReuseIdentifier: className)
    }
    
    func registerCellNibForClass(_ cellClass: AnyClass) {
        let className = String(describing: cellClass)
        self.register(UINib(nibName: className, bundle: Bundle(for: cellClass)), forCellWithReuseIdentifier: className)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T? {
        let classname = String(describing: type)
        return dequeueReusableCell(withReuseIdentifier: classname, for: indexPath) as? T
    }
}

open class LMCollectionView: UICollectionView {
    public func translatesAutoresizingMaskIntoConstraints() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    public static func mediaFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        return layout
    }
}
