//
//  LMFeedEditPostScreen.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 24/01/24.
//

import AVKit
import LikeMindsFeedUI
import UIKit

@IBDesignable
open class LMFeedEditPostScreen: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
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
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var topicView: LMFeedTopicView = {
        let view = LMUIComponents.shared.topicFeedView.init().translatesAutoresizingMaskIntoConstraints()
        view.delegate = self
        return view
    }()
    
    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView().translatesAutoresizingMaskIntoConstraints()
        textView.mentionDelegate = self
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.placeHolderText = "Write something here..."
        textView.addDoneButtonOnKeyboard()
        return textView
    }()
    
    open private(set) lazy var linkPreview: LMFeedLinkPreview = {
        let view = LMUIComponents.shared.linkPreview.init().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var mediaCollectionView: LMCollectionView = {
        let collection = LMCollectionView(frame: .zero, collectionViewLayout: LMCollectionView.mediaFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.registerCell(type: LMUIComponents.shared.imagePreview)
        collection.registerCell(type: LMUIComponents.shared.videoPreview)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        return collection
    }()
    
    open private(set) lazy var mediaPageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = true
        pageControl.tintColor = LMFeedAppearance.shared.colors.appTintColor
        pageControl.currentPageIndicatorTintColor = LMFeedAppearance.shared.colors.appTintColor
        pageControl.pageIndicatorTintColor = LMFeedAppearance.shared.colors.gray155
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
    
    open private(set) lazy var pollPreview: LMFeedCreateDisplayPollView = {
        let view = LMUIComponents.shared.createPollDisplayView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open private(set) lazy var saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
    
    open private(set) lazy var headingTextContainer: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var headingTextView: LMTextView = {
        let textView = LMTextView().translatesAutoresizingMaskIntoConstraints()
        textView.backgroundColor = LMFeedAppearance.shared.colors.clear
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.placeHolderText = "Add your question here"
        textView.textAttributes[.font] = LMFeedAppearance.shared.fonts.headingFont1
        textView.placeholderAttributes[.font] = LMFeedAppearance.shared.fonts.headingFont1
        return textView
    }()
    
    open private(set) lazy var headerSepratorView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.sepratorColor
        return view
    }()
    
    
    // MARK: Data Variables
    public var viewmodel: LMFeedEditPostViewModel?
    public var mediaCells: [LMFeedMediaProtocol] = []
    public var documentCells: [LMFeedDocumentPreview.ContentModel] = []
    
    public var taggingUserViewHeightConstraint: NSLayoutConstraint?
    public var inputTextViewHeightConstraint: NSLayoutConstraint?
    public var textInputMaximumHeight: CGFloat = 150
    public var showQuestionHeading: Bool = false {
        didSet {
            headingTextContainer.isHidden = !showQuestionHeading
        }
    }
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        containerView.addSubview(scrollView)
        scrollView.addSubview(scrollStackView)
        containerView.addSubview(taggingView)
        
        headingTextContainer.addSubview(headerSepratorView)
        headingTextContainer.addSubview(headingTextView)
        
        [headerView, topicView, headingTextContainer, inputTextView, linkPreview, pollPreview, mediaCollectionView, mediaPageControl, documentTableView].forEach { subview in
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
        
        headingTextContainer.pinSubView(subView: headingTextView)
        
        headerSepratorView.addConstraint(bottom: (headingTextContainer.bottomAnchor, 0),
                                         leading: (headingTextContainer.leadingAnchor, 0),
                                         trailing: (headingTextContainer.trailingAnchor, 0))
        headerSepratorView.setHeightConstraint(with: 1)
        
        headingTextContainer.setHeightConstraint(with: 100)
        
        [headerView, topicView, headingTextContainer, inputTextView, mediaCollectionView, mediaPageControl, documentTableView, pollPreview].forEach { subView in
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
        
        saveButton.tintColor = LMFeedAppearance.shared.colors.appTintColor
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc
    open func didTapSaveButton() {
        viewmodel?.updatePost(with: inputTextView.getText(), question: headingTextView.getText())
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        headingTextView.setAttributedText(from: "")
        setNavigationTitleAndSubtitle(with: LMStringConstants.shared.editPost, subtitle: nil, alignment: .center)
        viewmodel?.getInitalData()
        
        if showQuestionHeading {
            headingTextView.textChangedObserver = { [weak self] in
                self?.observeSaveButton()
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mediaCollectionView.visibleCells.forEach { cell in
            (cell as? LMFeedVideoCollectionCell)?.pauseVideo()
        }
    }
    
    open func setupInitialView() {
        linkPreview.isHidden = true
        taggingView.isHidden = true
        mediaCollectionView.isHidden = true
        mediaPageControl.isHidden = true
        documentTableView.isHidden = true
        pollPreview.isHidden = true
        showQuestionHeading = false
    }
}


// MARK: UITableView
extension LMFeedEditPostScreen: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        documentCells.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = documentCells[safe: indexPath.row],
           let cell = tableView.dequeueReusableCell(LMFeedCreatePostDocumentPreviewCell.self) {
            cell.configure(data: data, delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
}


// MARK: UICollectionView
extension LMFeedEditPostScreen: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mediaCells.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let data = mediaCells[safe: indexPath.row] as? LMFeedImageCollectionCell.ContentModel,
           let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.imagePreview, for: indexPath) {
            cell.configure(with: data)
            return cell
        } else if let data = mediaCells[safe: indexPath.row] as? LMFeedVideoCollectionCell.ContentModel,
                  let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.videoPreview, for: indexPath) {
            cell.configure(with: data, index: indexPath.row)
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }
        
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        mediaCollectionView.visibleCells.forEach { cell in
            (cell as? LMFeedVideoCollectionCell)?.pauseVideo()
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollingFinished()
        }
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingFinished()
    }

    public func scrollingFinished() {
        mediaPageControl.currentPage = Int(mediaCollectionView.contentOffset.x / mediaCollectionView.frame.width)
        
        if mediaCollectionView.visibleCells.count == 1 {
            (mediaCollectionView.visibleCells.first as? LMFeedVideoCollectionCell)?.playVideo()
        }
    }
}


// MARK: LMFeedTopicViewCellProtocol
extension LMFeedEditPostScreen: LMFeedTopicViewCellProtocol {
    public func didTapEditButton() {
        viewmodel?.didTapTopicSelection()
    }
    
    public func didTapSelectTopicButton() {
        viewmodel?.didTapTopicSelection()
    }
}


// MARK: LMFeedTaggingTextViewProtocol
@objc
extension LMFeedEditPostScreen: LMFeedTaggingTextViewProtocol {
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
        observeSaveButton()
    }
    
    public func observeSaveButton() {
        if showQuestionHeading {
            saveButton.isEnabled = !headingTextView.getText().isEmpty
        } else {
            saveButton.isEnabled = !inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !documentCells.isEmpty || !mediaCells.isEmpty
        }
    }
}


// MARK: LMFeedEditPostViewModelProtocol
extension LMFeedEditPostScreen: LMFeedEditPostViewModelProtocol {
    public func setupData(with userData: LMFeedCreatePostHeaderView.ContentModel, question: String, text: String) {
        headerView.configure(with: userData)
        showQuestionHeading = !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        headingTextView.text = question
        inputTextView.setAttributedText(from: text, prefix: "@")
        contentHeightChanged()
    }
    
    public func setupDocumentPreview(with data: [LMFeedDocumentPreview.ContentModel]) {
        self.documentCells = data
        
        documentTableView.isHidden = false
        documentTableView.reloadTable()
    }
    
    public func setupLinkPreview(with data: LMFeedLinkPreview.ContentModel?) {
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
        UIView.performWithoutAnimation {
            mediaCollectionView.reloadData()
        }
        scrollingFinished()
        mediaPageControl.isHidden = false
        mediaPageControl.numberOfPages = mediaCells.count
        mediaPageControl.currentPage = 0
    }
    
    public func navigateToTopicView(with topics: [LMFeedTopicDataModel]) {
        do {
            let viewcontroller = try LMFeedTopicSelectionViewModel.createModule(topicEnabledState: true, isShowAllTopicsButton: false, selectedTopicIds: topics, delegate: self)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func setupTopicFeed(with data: LMFeedTopicView.ContentModel) {
        topicView.isHidden = false
        topicView.configure(with: data)
    }
    
    public func setupPollPreview(with poll: LMFeedCreateDisplayPollView.ContentModel) {
        pollPreview.configure(with: poll, delegate: nil)
        pollPreview.isHidden = false
    }
}


// MARK: LMFeedDocumentPreviewProtocol
extension LMFeedEditPostScreen: LMFeedDocumentPreviewProtocol {
    public func didTapDocument(documentID: URL) {
        openURL(with: documentID)
    }
}


// MARK: LMFeedTaggedUserFoundProtocol
extension LMFeedEditPostScreen: LMFeedTaggedUserFoundProtocol {
    public func userSelected(with route: String, and userName: String) {
        inputTextView.addTaggedUser(with: userName, route: route)
    }
    
    public func updateHeight(with height: CGFloat) {
        taggingUserViewHeightConstraint?.constant = height
    }
}


// MARK: LMFeedTopicSelectionViewModelProtocol
extension LMFeedEditPostScreen: LMFeedTopicSelectionViewProtocol {
    public func updateTopicFeed(with topics: [LMFeedTopicDataModel]) {
        viewmodel?.updateTopicFeed(with: topics)
    }
}
