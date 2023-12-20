//
//  LMFeedTopicView.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 20/12/23.
//

import UIKit

public protocol LMFeedTopicViewCellProtocol: AnyObject {
    func didTapCrossButton(for topicId: String)
    func didTapEditButton()
}

@IBDesignable
open class LMFeedTopicView: LMView {
    public struct ViewModel {
        let topics: [LMFeedTopicCollectionCellDataModel]
        let isEditFlow: Bool
        let isSepratorShown: Bool
        
        init(topics: [LMFeedTopicCollectionCellDataModel], isEditFlow: Bool = false, isSepratorShown: Bool) {
            self.topics = topics
            self.isEditFlow = isEditFlow
            self.isSepratorShown = isSepratorShown
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        stack.backgroundColor = Appearance.shared.colors.clear
        return stack
    }()
    
    open private(set) lazy var collectionView: LMFeedTopicCollectionView = {
        let collection = LMFeedTopicCollectionView(frame: .zero, collectionViewLayout: TagsLayout()).translatesAutoresizingMaskIntoConstraints()
        collection.isScrollEnabled = false
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = Appearance.shared.colors.clear
        collection.registerCell(type: Components.shared.topicFeedCollectionCell)
        collection.registerCell(type: Components.shared.topicFeedEditIconCollectionCell)
        return collection
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.gray4
        return view
    }()
    
    
    // MARK: Data Variables
    public var topics: [LMFeedTopicCollectionCellDataModel] = []
    public var isEditFlow: Bool = false
    public weak var delegate: LMFeedTopicViewCellProtocol?
    
    
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(sepratorView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            sepratorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        let heightConstraint = NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel) {
        topics = data.topics
        isEditFlow = data.isEditFlow
        
        collectionView.reloadData()
        layoutIfNeeded()
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
@objc
extension LMFeedTopicView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topics.count + (isEditFlow ? 1 : 0)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: Components.shared.topicFeedCollectionCell, for: indexPath),
           let data = topics[safe: indexPath.row] {
            cell.configure(with: data)
            return cell
        } else if isEditFlow,
                  let cell = collectionView.dequeueReusableCell(with: Components.shared.topicFeedEditIconCollectionCell, for: indexPath) {
            cell.configure { [weak self] in
                self?.delegate?.didTapEditButton()
            }
        }
        
        return UICollectionViewCell()
    }
}
