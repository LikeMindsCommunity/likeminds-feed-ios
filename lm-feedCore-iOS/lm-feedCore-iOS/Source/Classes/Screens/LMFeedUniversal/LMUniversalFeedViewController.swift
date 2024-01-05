//
//  LMUniversalFeedViewController.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import lm_feedUI_iOS
import UIKit

open class LMUniversalFeedViewController: LMViewController {
    // MARK: UI Elements
    
    open private(set) lazy var contentStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.backgroundColor = Appearance.shared.colors.clear
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var topicContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var topicStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.backgroundColor = Appearance.shared.colors.white
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var allTopicsButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(Constants.shared.strings.allTopics, for: .normal)
        button.setImage(Constants.shared.images.downArrow, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont2)
        button.setTitleColor(Appearance.shared.colors.gray102, for: .normal)
        button.tintColor = Appearance.shared.colors.gray102
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()
    
    open private(set) lazy var topicCollection: LMCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = .init(width: 100, height: 30)
        
        let collection = LMCollectionView(frame: .zero, collectionViewLayout: layout).translatesAutoresizingMaskIntoConstraints()
        collection.dataSource = self
        collection.delegate = self
        collection.registerCell(type: LMUIComponents.shared.topicFeedEditCollectionCell)
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = Appearance.shared.colors.clear
        return collection
    }()
    
    open private(set) lazy var clearButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setFont(Appearance.shared.fonts.buttonFont2)
        button.setTitleColor(Appearance.shared.colors.gray102, for: .normal)
        button.setTitle("Clear", for: .normal)
        button.setImage(nil, for: .normal)
        button.tintColor = Appearance.shared.colors.gray102
        return button
    }()
    
    open private(set) lazy var postList: LMFeedPostListViewController = {
        let vc = LMFeedPostListViewModel.createModule(with: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    
    // MARK: Data Variables
    public var data: [LMFeedPostTableCellProtocol] = []
    public var selectedTopics: [LMFeedTopicCollectionCellDataModel] = []
    public var viewModel: LMUniversalFeedViewModel?
    public weak var feedListDelegate: LMFeedPostListVCToProtocol?
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        allTopicsButton.isHidden = !selectedTopics.isEmpty
        topicCollection.isHidden = selectedTopics.isEmpty
        clearButton.isHidden = selectedTopics.isEmpty
    }
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        view.addSubview(contentStack)
        
        contentStack.addArrangedSubview(topicContainerView)
        addChild(postList)
        contentStack.addArrangedSubview(postList.view)
        postList.didMove(toParent: self)
        
        topicContainerView.addSubview(topicStackView)
        topicStackView.addArrangedSubview(allTopicsButton)
        topicStackView.addArrangedSubview(topicCollection)
        topicStackView.addArrangedSubview(clearButton)
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            topicContainerView.heightAnchor.constraint(equalToConstant: 50),
            topicStackView.leadingAnchor.constraint(equalTo: topicContainerView.leadingAnchor, constant: 16),
            topicStackView.trailingAnchor.constraint(lessThanOrEqualTo: topicContainerView.trailingAnchor, constant: -16),
            topicStackView.topAnchor.constraint(equalTo: topicContainerView.topAnchor),
            topicStackView.bottomAnchor.constraint(equalTo: topicContainerView.bottomAnchor),
            
            topicCollection.topAnchor.constraint(equalTo: topicStackView.topAnchor),
            topicCollection.bottomAnchor.constraint(equalTo: topicStackView.bottomAnchor),
            topicCollection.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        allTopicsButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        clearButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let topicWidth = NSLayoutConstraint(item: topicCollection, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 500)
        topicWidth.priority = .defaultLow
        topicWidth.isActive = true
    }
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        allTopicsButton.addTarget(self, action: #selector(didTapAllTopicsButton), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        feedListDelegate = postList
    }
    
    @objc
    open func didTapNavigationMenuButton() {
        print(#function)
    }
    
    @objc
    open func didTapAllTopicsButton() {
        let viewController = LMFeedTopicSelectionViewModel.createModule(topicEnabledState: false, isShowAllTopicsButton: true, delegate: self)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    open func didTapClearButton() {
        viewModel?.updateSelectedTopics(with: [])
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = Appearance.shared.colors.backgroundColor
    }
    
    // MARK: setupNavigationBar
    open override func setupNavigationBar() {
        super.setupNavigationBar()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.shared.images.menuIcon, style: .plain, target: self, action: #selector(didTapNavigationMenuButton))
        navigationController?.navigationBar.backgroundColor = Appearance.shared.colors.navigationBackgroundColor
        setNavigationTitleAndSubtitle(with: Constants.shared.strings.communityHood, subtitle: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Constants.shared.images.personIcon, style: .plain, target: nil, action: nil)
    }
}


// MARK: UICollectionView
@objc
extension LMUniversalFeedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedTopics.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.topicFeedEditCollectionCell, for: indexPath),
           let data = selectedTopics[safe: indexPath.row] {
            cell.configure(with: data, delegate: self)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = selectedTopics[indexPath.row].topic.sizeOfString(with: Appearance.shared.fonts.textFont1)
        return .init(width: size.width + 40, height: 30)
    }
}


// MARK: LMUniversalFeedViewModelProtocol
extension LMUniversalFeedViewController: LMUniversalFeedViewModelProtocol {
    public func loadTopics(with topics: [LMFeedTopicCollectionCellDataModel]) {
        self.selectedTopics = topics
        feedListDelegate?.loadPostsWithTopics(selectedTopics.map { $0.topicID })
        
        topicCollection.reloadData()

        allTopicsButton.isHidden = !topics.isEmpty
        topicCollection.isHidden = topics.isEmpty
        clearButton.isHidden = topics.isEmpty
    }
}


// MARK: LMFeedTopicSelectionViewProtocol
extension LMUniversalFeedViewController: LMFeedTopicSelectionViewProtocol {
    public func updateTopicFeed(with topics: [(topicName: String, topicID: String)]) {
        viewModel?.updateSelectedTopics(with: topics)
    }
}


// MARK: LMFeedTopicViewCellProtocol
@objc
extension LMUniversalFeedViewController: LMFeedTopicViewCellProtocol {
    open func didTapCrossButton(for topicId: String) {
        viewModel?.removeTopic(id: topicId)
    }
}

// MARK: LMFeedPostListVCFromProtocol
@objc
extension LMUniversalFeedViewController: LMFeedPostListVCFromProtocol {
    open func openPostDetail(for postID: String) {
        let viewController = LMFeedPostDetailViewModel.createModule(for: postID)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    open func openUserDetail(for uuid: String) {
        print(#function)
    }
}
