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
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }
    
    public func isCellAtIndexPathFullyVisible(_ indexPath: IndexPath) -> Bool {
        guard let layoutAttribute = layoutAttributesForItem(at: indexPath) else {
            return false
        }
        
        let cellFrame = layoutAttribute.frame
        return self.bounds.contains(cellFrame)
    }
    
    public func indexPathsForFullyVisibleItems() -> [IndexPath] {
        let visibleIndexPaths = indexPathsForVisibleItems
        
        return visibleIndexPaths.filter { indexPath in
            return isCellAtIndexPathFullyVisible(indexPath)
        }
    }
}
