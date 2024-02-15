//
//  LMFeedEditPostViewController.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 24/01/24.
//

import AVKit
import lm_feedUI_iOS
import UIKit

@IBDesignable
open class LMFeedEditPostViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isDirectionalLockEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.bounces = false
        return scroll
    }()
    
    open private(set) lazy var scrollStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var headerView: LMFeedCreatePostHeaderView = {
        let view = LMUIComponents.shared.createPostHeaderView.init().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var topicView: LMFeedTopicView = {
        let view = LMUIComponents.shared.topicFeed.init().translatesAutoresizingMaskIntoConstraints()
        view.delegate = self
        return view
    }()
    
    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView().translatesAutoresizingMaskIntoConstraints()
        textView.mentionDelegate = self
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.placeHolderText = "Write Something here..."
        textView.addDoneButtonOnKeyboard()
        return textView
    }()
    
    open private(set) lazy var linkPreview: LMFeedLinkPreview = {
        let view = LMUIComponents.shared.linkPreview.init().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var mediaCollectionView: LMCollectionView = {
        let collection = LMCollectionView(frame: .zero, collectionViewLayout: LMCollectionView.mediaFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.registerCell(type: LMUIComponents.shared.imagePreviewCell)
        collection.registerCell(type: LMUIComponents.shared.videoPreviewCell)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    open private(set) lazy var mediaPageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = true
        pageControl.tintColor = Appearance.shared.colors.appTintColor
        pageControl.currentPageIndicatorTintColor = Appearance.shared.colors.appTintColor
        pageControl.pageIndicatorTintColor = Appearance.shared.colors.gray155
        return pageControl
    }()
    
    open private(set) lazy var documentTableView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.isScrollEnabled = false
        table.alwaysBounceVertical = false
        table.alwaysBounceHorizontal = false
        table.register(LMFeedCreatePostDocumentPreviewCell.self)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        return table
    }()
    
    open private(set) lazy var videoPlayer: AVPlayerViewController = {
        let player = AVPlayerViewController()
        player.view.translatesAutoresizingMaskIntoConstraints = false
        player.showsPlaybackControls = false
        return player
    }()
    
    open private(set) lazy var taggingView: LMFeedTaggingListView = {
        let view = LMFeedTaggingListViewModel.createModule(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open private(set) lazy var saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
    
    
    // MARK: Data Variables
    public var viewmodel: LMFeedEditPostViewModel?
    public var mediaCells: [LMFeedMediaProtocol] = []
    public var documentCells: [LMFeedDocumentPreview.ViewModel] = []
    
    public var taggingUserViewHeightConstraint: NSLayoutConstraint?
    public var inputTextViewHeightConstraint: NSLayoutConstraint?
    public var textInputMaximumHeight: CGFloat = 150
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        containerView.addSubview(scrollView)
        scrollView.addSubview(scrollStackView)
        containerView.addSubview(taggingView)
        
        [headerView, topicView, inputTextView, linkPreview, mediaCollectionView, mediaPageControl, documentTableView].forEach { subview in
            scrollStackView.addArrangedSubview(subview)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        view.pinSubView(subView: containerView)
        containerView.pinSubView(subView: scrollView)
        scrollView.pinSubView(subView: scrollStackView)
        
        scrollStackView.setHeightConstraint(with: 1000, priority: .defaultLow)
        headerView.setHeightConstraint(with: 64)
        
        inputTextViewHeightConstraint = inputTextView.setHeightConstraint(with: 80)
        
        taggingView.addConstraint(top: (inputTextView.bottomAnchor, 0),
                                  leading: (inputTextView.leadingAnchor, 0),
                                  trailing: (inputTextView.trailingAnchor, 0))
        taggingUserViewHeightConstraint = taggingView.setHeightConstraint(with: 10, priority: .defaultLow)
        
        scrollView.setWidthConstraint(with: containerView.widthAnchor)
        scrollStackView.setWidthConstraint(with: containerView.widthAnchor)
        mediaCollectionView.setHeightConstraint(with: mediaCollectionView.widthAnchor)
        
        
        [headerView, topicView, inputTextView, mediaCollectionView, mediaPageControl, documentTableView].forEach { subView in
            NSLayoutConstraint.activate([
                subView.leadingAnchor.constraint(equalTo: scrollStackView.leadingAnchor, constant: 16),
                subView.trailingAnchor.constraint(equalTo: scrollStackView.trailingAnchor, constant: -16)
            ])
        }
        
        linkPreview.addConstraint(leading: (scrollStackView.leadingAnchor, 0),
                                  trailing: (scrollStackView.trailingAnchor, 0))
    }
    
    
    open override func setupActions() {
        super.setupActions()
        
        saveButton.tintColor = Appearance.shared.colors.appTintColor
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc
    open func didTapSaveButton() {
        viewmodel?.updatePost(with: inputTextView.getText())
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = Appearance.shared.colors.white
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        viewmodel?.getInitalData()
    }
    
    open func setupInitialView() {
        linkPreview.isHidden = true
        mediaCollectionView.isHidden = true
        mediaPageControl.isHidden = true
        documentTableView.isHidden = true
    }
}


// MARK: UITableView
extension LMFeedEditPostViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        documentCells.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMFeedCreatePostDocumentPreviewCell.self),
           let data = documentCells[safe: indexPath.row] {
            cell.configure(data: data, delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
}


// MARK: UICollectionView
extension LMFeedEditPostViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mediaCells.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.imagePreviewCell, for: indexPath),
           let data = mediaCells[safe: indexPath.row] as? LMFeedImageCollectionCell.ViewModel {
            cell.configure(with: data)
            return cell
        } else if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.videoPreviewCell, for: indexPath),
                  let data = mediaCells[safe: indexPath.row] as? LMFeedVideoCollectionCell.ViewModel {
            cell.configure(with: data, videoPlayer: videoPlayer)
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mediaPageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            mediaPageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        }
    }
}


// MARK: LMFeedTopicViewCellProtocol
extension LMFeedEditPostViewController: LMFeedTopicViewCellProtocol {
    public func didTapEditButton() {
        viewmodel?.didTapTopicSelection()
    }
    
    public func didTapSelectTopicButton() {
        viewmodel?.didTapTopicSelection()
    }
}


// MARK: LMFeedTaggingTextViewProtocol
@objc
extension LMFeedEditPostViewController: LMFeedTaggingTextViewProtocol {
    open func mentionStarted(with text: String) {
        taggingView.getUsers(for: text)
        taggingView.isHidden = false
    }
    
    open func mentionStopped() {
        taggingView.stopFetchingUsers()
        taggingView.isHidden = true
    }
    
    open func contentHeightChanged() {
        let width = inputTextView.frame.size.width
        let newSize = inputTextView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        inputTextView.isScrollEnabled = newSize.height > textInputMaximumHeight
        inputTextViewHeightConstraint?.constant = min(max(newSize.height, 80), textInputMaximumHeight)
        
        viewmodel?.handleLinkDetection(in: inputTextView.text)
        saveButton.isEnabled = !inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !documentCells.isEmpty || !mediaCells.isEmpty
    }
}


// MARK: LMFeedEditPostViewModelProtocol
extension LMFeedEditPostViewController: LMFeedEditPostViewModelProtocol {
    public func setupData(with userData: LMFeedCreatePostHeaderView.ViewDataModel, text: String) {
        headerView.configure(with: userData)
        inputTextView.setAttributedText(from: text, prefix: "@")
        contentHeightChanged()
    }
    
    public func setupDocumentPreview(with data: [LMFeedDocumentPreview.ViewModel]) {
        self.documentCells = data
        
        documentTableView.isHidden = false
        documentTableView.reloadData()
    }
    
    public func setupLinkPreview(with data: LMFeedLinkPreview.ViewModel?) {
        linkPreview.isHidden = data == nil
        
        if let data {
            linkPreview.configure(with: data) { [weak self] in
                self?.linkPreview.isHidden = true
                self?.viewmodel?.hideLinkPreview()
            }
        }
    }
    
    public func setupMediaPreview(with mediaCells: [LMFeedMediaProtocol]) {
        self.mediaCells = mediaCells
        
        mediaCollectionView.isHidden = false
        mediaCollectionView.reloadData()

        mediaPageControl.isHidden = false
        mediaPageControl.numberOfPages = mediaCells.count
        mediaPageControl.currentPage = 0
    }
    
    public func showErrorMessage(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        presentAlert(with: alert)
    }
    
    public func navigateToTopicView(with topics: [String]) {
        do {
            let viewcontroller = try LMFeedTopicSelectionViewModel.createModule(topicEnabledState: false, isShowAllTopicsButton: false, selectedTopicIds: topics, delegate: self)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func setupTopicFeed(with data: LMFeedTopicView.ViewModel) {
        topicView.isHidden = false
        topicView.configure(with: data)
    }
}


// MARK: LMFeedDocumentPreviewProtocol
extension LMFeedEditPostViewController: LMFeedDocumentPreviewProtocol {
    public func didTapDocument(documentID: String) {
        guard let url = URL(string: documentID) else { return }
        UIApplication.shared.open(url)
    }
}


// MARK: LMFeedTaggedUserFoundProtocol
extension LMFeedEditPostViewController: LMFeedTaggedUserFoundProtocol {
    public func userSelected(with route: String, and userName: String) {
        inputTextView.addTaggedUser(with: userName, route: route)
    }
    
    public func updateHeight(with height: CGFloat) {
        taggingUserViewHeightConstraint?.constant = height
    }
}


// MARK: LMFeedTopicSelectionViewModelProtocol
extension LMFeedEditPostViewController: LMFeedTopicSelectionViewProtocol {
    public func updateTopicFeed(with topics: [(topicName: String, topicID: String)]) {
        viewmodel?.updateTopicFeed(with: topics)
    }
}
