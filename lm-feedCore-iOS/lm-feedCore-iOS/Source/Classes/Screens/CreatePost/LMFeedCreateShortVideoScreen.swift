//
//  LMFeedCreateShortVideoScreen.swift
//  lm-feedCore-iOS
//
//  Created by Arpit Verma on 16/05/25.
//

import AVKit
import BSImagePicker
import LikeMindsFeedUI
import UIKit
import Photos

open class LMFeedCreateShortVideoScreen: LMFeedViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var containerStackView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
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
    
    open private(set) lazy var scrollStackView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    
    open private(set) lazy var topicView: LMFeedTopicView = {
        let view = LMUIComponents.shared.topicFeedView.init().translatesAutoresizingMaskIntoConstraints()
        view.delegate = self
        return view
    }()
    
    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView().translatesAutoresizingMaskIntoConstraints()
        textView.dataDetectorTypes = [.link]
        textView.mentionDelegate = self
        textView.backgroundColor = LMFeedAppearance.shared.colors.clear
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.placeHolderText = "Write a caption and hashtags..."
        textView.backgroundColor = LMFeedAppearance.shared.colors.clear
        textView.addDoneButtonOnKeyboard()
        return textView
    }()
    
    open private(set) lazy var videoPreview: LMFeedCollectionView = {
        let collection = LMFeedCollectionView(frame: .zero, collectionViewLayout: LMFeedCollectionView.mediaFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.registerCell(type: LMUIComponents.shared.videoPreview)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.layer.cornerRadius = 12
        collection.clipsToBounds = true
        collection.backgroundColor = .black
        return collection
    }()
    
    open private(set) lazy var createPostButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: LMStringConstants.shared.postText, style: .plain, target: self, action: #selector(didTapCreateButton))
        button.tintColor = LMFeedAppearance.shared.colors.appTintColor
        return button
    }()
    
    // MARK: Data Variables
    public var viewModel: LMFeedCreateShortVideoViewModel?
    public var videoAttachmentData: [LMFeedMediaProtocol] = []
    private var videoCollectionViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        containerView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(scrollView)
        scrollView.addSubview(scrollStackView)
        
        [ videoPreview, topicView, inputTextView].forEach { subView in
            scrollStackView.addArrangedSubview(subView)
        }
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.safePinSubView(subView: containerView)
        containerView.pinSubView(subView: containerStackView)
        scrollView.pinSubView(subView: scrollStackView, padding: .init(top: 8, left: 0, bottom: -8, right: 0))
        
        topicView.setHeightConstraint(with: 2, priority: .defaultLow)
        
        scrollStackView.setWidthConstraint(with: containerView.widthAnchor, multiplier: 1)
        scrollStackView.setHeightConstraint(with: 700, priority: .defaultLow)
        
        // Update video preview constraints
        videoPreview.setWidthConstraint(with: containerStackView.widthAnchor, multiplier: 0.9)
        videoPreview.setHeightConstraint(with: videoPreview.widthAnchor, multiplier: 1.3)
        videoPreview.addConstraint(leading: (containerStackView.leadingAnchor, 20))
        videoPreview.topAnchor.constraint(equalTo: scrollStackView.topAnchor, constant: 25).isActive = true
        
        scrollStackView.subviews.forEach { subView in
            if subView != videoPreview {
                NSLayoutConstraint.activate([
                    subView.leadingAnchor.constraint(equalTo: scrollStackView.leadingAnchor, constant: 16),
                    subView.trailingAnchor.constraint(equalTo: scrollStackView.trailingAnchor, constant: -16)
                ])
            }
        }
    }
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        navigationItem.rightBarButtonItem = createPostButton
    }
    
    @objc
    open func didTapCreateButton() {
        viewModel?.createReel(with: inputTextView.getText())
    }
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        
        // Configure navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isTranslucent = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = LMFeedAppearance.shared.colors.appTintColor
        
        setNavigationTitleAndSubtitle(with: "New Reel", subtitle: nil, alignment: .leading)
        
        inputTextView.setAttributedText(from: "")
        setupInitialView()
        
        viewModel?.getTopics()
    }
    
    // MARK: Status Bar
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPreview.visibleCells.forEach { cell in
            (cell as? LMFeedVideoCollectionCell)?.pauseVideo()
        }
    }
    
    open func setupInitialView() {
        videoPreview.isHidden = false
        topicView.isHidden = true
        createPostButton.isEnabled = false
    }
    
    open func observeCreateButton() {
        createPostButton.isEnabled = !videoAttachmentData.isEmpty || !inputTextView.getText().isEmpty
    }
}

// MARK: UICollectionView
extension LMFeedCreateShortVideoScreen: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { videoAttachmentData.count }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let data = videoAttachmentData[indexPath.row] as? LMFeedVideoCollectionCell.ContentModel,
           let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.videoPreview, for: indexPath) {
            let modifiedData = LMFeedVideoCollectionCell.ContentModel(
                videoURL: data.videoURL,
                isFilePath: data.isFilePath,
                postID: data.postID,
                width: data.width,
                height: data.height,
                showRemoveButton: false
            )
            cell.configure(with: modifiedData, index: indexPath.row) { _ in }
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: width * 1.3)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        videoPreview.visibleCells.forEach { cell in
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
        let visibleCount = videoPreview.indexPathsForFullyVisibleItems()
        if visibleCount.count == 1,
           let index = visibleCount.first {
            (videoPreview.cellForItem(at: index) as? LMFeedVideoCollectionCell)?.playVideo()
        }
    }
}

extension LMFeedCreateShortVideoScreen : LMFeedCreateShortVideoViewModelProtocol {
    public func showVideo(video: [LMFeedMediaProtocol]) {
        videoPreview.isHidden = video.isEmpty
        videoAttachmentData = video
        videoPreview.reloadData()
        observeCreateButton()
    }
    
    public func resetMediaView() {
        videoPreview.isHidden = false
        videoAttachmentData.removeAll()
    }
    
    
    public func updateTopicView(with data: LMFeedTopicView.ContentModel) {
        topicView.isHidden = false
        topicView.configure(with: data)
    }
    
    public func navigateToTopicView(with topics: [LMFeedTopicDataModel]) {
        do {
            let viewcontroller = try LMFeedTopicSelectionViewModel.createModule(topicEnabledState: true, isShowAllTopicsButton: false, selectedTopicIds: topics, delegate: self)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}

// MARK: LMFeedTaggingTextViewProtocol
extension LMFeedCreateShortVideoScreen: LMFeedTaggingTextViewProtocol {
    public func mentionStarted(with text: String) {
        // Handle mentions if needed
    }
    
    public func mentionStopped() {
        // Handle mentions if needed
    }
    
    public func contentHeightChanged() {
        observeCreateButton()
    }
}

// MARK: LMFeedTopicViewCellProtocol
extension LMFeedCreateShortVideoScreen: LMFeedTopicViewCellProtocol {
    public func didTapEditButton() {
        viewModel?.didTapTopicSelection()
    }
    
    public func didTapSelectTopicButton() {
        viewModel?.didTapTopicSelection()
    }
}

// MARK: LMFeedTopicSelectionViewProtocol
extension LMFeedCreateShortVideoScreen: LMFeedTopicSelectionViewProtocol {
    public func updateTopicFeed(with topics: [LMFeedTopicDataModel]) {
        viewModel?.updateTopicFeed(with: topics)
    }
}


