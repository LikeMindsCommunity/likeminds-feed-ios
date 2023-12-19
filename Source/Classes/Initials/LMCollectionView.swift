//
//  LMCollectionView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 01/12/23.
//

import UIKit

extension UICollectionView {
    public func registerCell(type: UICollectionViewCell.Type) {
        let className = String(describing: type)
        register(type, forCellWithReuseIdentifier: className)
    }
    
    public func registerCellNibForClass(_ cellClass: AnyClass) {
        let className = String(describing: cellClass)
        self.register(UINib(nibName: className, bundle: Bundle(for: cellClass)), forCellWithReuseIdentifier: className)
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T? {
        let classname = String(describing: type)
        return dequeueReusableCell(withReuseIdentifier: classname, for: indexPath) as? T
    }
}

open class LMCollectionView: UICollectionView { }
