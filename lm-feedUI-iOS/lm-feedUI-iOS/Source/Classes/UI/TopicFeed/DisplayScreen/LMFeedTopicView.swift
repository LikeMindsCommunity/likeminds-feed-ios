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
    func didTapSelectTopicButton()
}

public extension LMFeedTopicViewCellProtocol {
    func didTapCrossButton(for topicId: String) { }
    func didTapEditButton() { }
    func didTapSelectTopicButton() { }
}

@IBDesignable
open class LMFeedTopicView: LMView {
    public struct ViewModel {
        public let topics: [LMFeedTopicCollectionCellDataModel]
        public let isSelectFlow: Bool
        public let isEditFlow: Bool
        public let isSepratorShown: Bool
        
        public init(topics: [LMFeedTopicCollectionCellDataModel]? = nil, isSelectFlow: Bool = false, isEditFlow: Bool = false, isSepratorShown: Bool = false) {
            self.topics = topics ?? []
            self.isSelectFlow = isSelectFlow
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
        collection.registerCell(type: LMUIComponents.shared.topicFeedCollectionCell)
        collection.registerCell(type: LMUIComponents.shared.topicFeedEditIconCollectionCell)
        collection.registerCell(type: LMUIComponents.shared.topicSelectIconCollectionCell)
        return collection
    }()
    
    open private(set) lazy var sepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.sepratorColor
        return view
    }()
    
    
    // MARK: Data Variables
    public var topics: [LMFeedTopicCollectionCellDataModel] = []
    public var isEditFlow: Bool = false
    public var isSelectFlow: Bool = false
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
        pinSubView(subView: containerView)
        containerView.pinSubView(subView: stackView, padding: .init(top: 8, left: 0, bottom: 0, right: 0))
        sepratorView.setHeightConstraint(with: 1)
    }
    
    
    // MARK: configure
    open func configure(with data: ViewModel) {
        topics = data.topics
        isEditFlow = data.isEditFlow
        isSelectFlow = data.isSelectFlow
        sepratorView.isHidden = !data.isSepratorShown
        
        collectionView.reloadData()
        layoutIfNeeded()
        
        DispatchQueue.main.async {
            print(self.collectionView.contentSize)
        }
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
@objc
extension LMFeedTopicView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topics.count + (isEditFlow ? 1 : 0) + (isSelectFlow ? 1 : 0)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.topicFeedCollectionCell, for: indexPath),
           let data = topics[safe: indexPath.row] {
            cell.configure(with: data)
            return cell
        } else if isEditFlow,
                  let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.topicFeedEditIconCollectionCell, for: indexPath) {
            cell.configure { [weak self] in
                self?.delegate?.didTapEditButton()
            }
            return cell
        } else if isSelectFlow,
                  let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.topicSelectIconCollectionCell, for: indexPath) {
            cell.configure { [weak self] in
                self?.delegate?.didTapSelectTopicButton()
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = topics[safe: indexPath.row]?.topic.sizeOfString(with: Appearance.shared.fonts.textFont2)
        let width = size?.width ?? 50
        
        return .init(width: width, height: 50)
    }
}
