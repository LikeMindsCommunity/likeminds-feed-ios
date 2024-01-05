//
//  LMFeedTopicCollectionView.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 20/12/23.
//

import UIKit

@IBDesignable
open class LMFeedTopicCollectionView: LMCollectionView {
    open override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    open override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    open override var intrinsicContentSize: CGSize {
        return contentSize
    }
}


public class TagsLayout: UICollectionViewFlowLayout {
    required public override init() {
        super.init()
        common()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        common()
    }
    
    private func common() {
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let att = super.layoutAttributesForElements(in:rect) else {return []}
        var x: CGFloat = sectionInset.left
        var y: CGFloat = -1.0
        
        for a in att {
            if a.representedElementCategory != .cell { continue }
            
            if a.frame.origin.y >= y { x = sectionInset.left }
            a.frame.origin.x = x
            x += a.frame.width + minimumInteritemSpacing
            y = a.frame.maxY
        }
        return att
    }
}
