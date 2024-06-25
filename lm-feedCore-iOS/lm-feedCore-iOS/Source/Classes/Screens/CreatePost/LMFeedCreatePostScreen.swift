//
//  LMFeedCreatePostScreen.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 16/01/24.
//

import AVKit
import BSImagePicker
import LikeMindsFeedUI
import UIKit
import Photos

@IBDesignable
open class LMFeedCreatePostScreen: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var containerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
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
        let view = LMUIComponents.shared.topicFeedView.init().translatesAutoresizingMaskIntoConstraints()
        view.delegate = self
        return view
    }()
    
    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView().translatesAutoresizingMaskIntoConstraints()
        textView.dataDetectorTypes = [.link]
        textView.mentionDelegate = self
        textView.backgroundColor = Appearance.shared.colors.clear
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.placeHolderText = "Write Something here..."
        textView.backgroundColor = Appearance.shared.colors.clear
        textView.addDoneButtonOnKeyboard()
        return textView
    }()
    
    open private(set) lazy var linkPreview: LMFeedLinkPreview = {
        let view = LMUIComponents.shared.linkPreview.init().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var pollPreview: LMFeedCreateDisplayPollView = {
        let view = LMUIComponents.shared.createPollDisplayView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open private(set) lazy var mediaCollectionView: LMCollectionView = {
        let collection = LMCollectionView(frame: .zero, collectionViewLayout: LMCollectionView.mediaFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.registerCell(type: LMUIComponents.shared.imagePreview)
        collection.registerCell(type: LMUIComponents.shared.videoPreview)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
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
        table.backgroundColor = Appearance.shared.colors.clear
        return table
    }()
    
    open private(set) lazy var addMoreButton: LMButton = {
        let button = LMButton.createButton(with: LMStringConstants.shared.addMoreText, image: Constants.shared.images.plusIcon, textColor: Appearance.shared.colors.appTintColor, textFont: Appearance.shared.fonts.buttonFont1, contentSpacing: .init(top: 8, left: 16, bottom: 8, right: 16))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = Appearance.shared.colors.appTintColor
        button.layer.borderColor = Appearance.shared.colors.appTintColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        return button
    }()
    
    
    open private(set) lazy var addMediaStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    open private(set) lazy var addPhotosTab: LMFeedAddMediaView = {
        let view = LMUIComponents.shared.addMediaView.init().translatesAutoresizingMaskIntoConstraints()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var addVideoTab: LMFeedAddMediaView = {
        let view = LMUIComponents.shared.addMediaView.init().translatesAutoresizingMaskIntoConstraints()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var addDocumentsTab: LMFeedAddMediaView = {
        let view = LMUIComponents.shared.addMediaView.init().translatesAutoresizingMaskIntoConstraints()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var addPollTab: LMFeedAddMediaView = {
        let view = LMUIComponents.shared.addMediaView.init().translatesAutoresizingMaskIntoConstraints()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var videoPlayer: AVPlayerViewController = {
        let player = AVPlayerViewController()
        player.view.translatesAutoresizingMaskIntoConstraints = false
        player.showsPlaybackControls = true
        return player
    }()
    
    open private(set) lazy var taggingView: LMFeedTaggingListView = {
        let view = LMFeedTaggingListViewModel.createModule(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open private(set) lazy var createPostButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: LMStringConstants.shared.doneText, style: .plain, target: self, action: #selector(didTapCreateButton))
        button.tintColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    
    // MARK: Data Variables
    public var viewModel: LMFeedCreatePostViewModel?
    public var documentAttachmentData: [LMFeedDocumentPreview.ContentModel] = []
    public var documenTableHeight: NSLayoutConstraint?
    public var documentAttachmentHeight: CGFloat = 90
    
    public var taggingViewHeight: NSLayoutConstraint?
    public var inputTextViewHeightConstraint: NSLayoutConstraint?
    public var textInputMinimumHeight: CGFloat = 80
    public var textInputMaximumHeight: CGFloat = 150
    
    public var isPollFlow: Bool = false
    
    public var mediaAttachmentData: [LMFeedMediaProtocol] = []
    
    public lazy var documentPicker: UIDocumentPickerViewController = {
        if #available(iOS 14, *) {
            let doc = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
            doc.delegate = self
            return doc
        } else {
            let doc = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
            doc.delegate = self
            return doc
        }
    }()
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        
        containerView.addSubview(containerStackView)
        containerView.addSubview(taggingView)
        
        containerStackView.addArrangedSubview(scrollView)
        containerStackView.addArrangedSubview(addMediaStack)
        
        scrollView.addSubview(scrollStackView)
        
        [headerView, topicView, inputTextView, linkPreview, pollPreview, mediaCollectionView, mediaPageControl ,documentTableView, addMoreButton].forEach { subView in
            scrollStackView.addArrangedSubview(subView)
        }
        
        [addPhotosTab, addVideoTab, addDocumentsTab, addPollTab].forEach { subView in
            addMediaStack.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        
        view.safePinSubView(subView: containerView)
        
        containerView.pinSubView(subView: containerStackView)
        scrollView.pinSubView(subView: scrollStackView, padding: .init(top: 8, left: 0, bottom: 8, right: 0))
        headerView.setHeightConstraint(with: 64)
        topicView.setHeightConstraint(with: 2, priority: .defaultLow)
        linkPreview.setHeightConstraint(with: 1000, priority: .defaultLow)
        addPhotosTab.setHeightConstraint(with: 40)
        
        scrollStackView.setWidthConstraint(with: containerView.widthAnchor, multiplier: 1)
        scrollStackView.setHeightConstraint(with: 1000, priority: .defaultLow)
        
        taggingView.addConstraint(top: (inputTextView.bottomAnchor, 0),
                                  leading: (inputTextView.leadingAnchor, 0),
                                  trailing: (inputTextView.trailingAnchor, 0))
        
        taggingView.bottomAnchor.constraint(lessThanOrEqualTo: scrollStackView.bottomAnchor, constant: -16).isActive = true
        taggingViewHeight = taggingView.setHeightConstraint(with: 10)
        
        inputTextViewHeightConstraint = inputTextView.setHeightConstraint(with: textInputMinimumHeight)
        
        documenTableHeight = documentTableView.setHeightConstraint(with: documentAttachmentHeight)
        scrollView.setWidthConstraint(with: containerStackView.widthAnchor)
        scrollStackView.setWidthConstraint(with: containerStackView.widthAnchor)
        mediaCollectionView.setHeightConstraint(with: mediaCollectionView.widthAnchor)
        
        scrollStackView.subviews.forEach { subView in
            if subView != addMoreButton {
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
        
        addPhotosTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddPhoto)))
        addVideoTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddVideo)))
        addDocumentsTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddDocument)))
        addPollTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddPoll)))
        addMoreButton.addTarget(self, action: #selector(didTapAddMoreButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = createPostButton
    }
    
    @objc
    open func didTapAddPhoto() {
        LMFeedCore.analytics?.trackEvent(for: .postCreationAttachmentClicked, eventProperties: ["type": "image"])
        viewModel?.updateCurrentSelection(to: .image)
    }
    
    @objc
    open func didTapAddVideo() {
        LMFeedCore.analytics?.trackEvent(for: .postCreationAttachmentClicked, eventProperties: ["type": "video"])
        viewModel?.updateCurrentSelection(to: .video)
    }
    
    @objc
    open func didTapAddDocument() {
        LMFeedCore.analytics?.trackEvent(for: .postCreationAttachmentClicked, eventProperties: ["type": "file"])
        viewModel?.updateCurrentSelection(to: .document)
    }
    
    @objc
    open func didTapAddPoll() {
        LMFeedCore.analytics?.trackEvent(for: .postCreationAttachmentClicked, eventProperties: ["type": "poll"])
        viewModel?.updateCurrentSelection(to: .poll)
    }
    
    @objc
    open func didTapAddMoreButton() {
        viewModel?.addMoreButtonClicked()
    }
    
    @objc
    open func didTapCreateButton() {
        viewModel?.createPost(with: inputTextView.getText())
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.shared.colors.white
        setNavigationTitleAndSubtitle(with: LMStringConstants.shared.createPostNavTitle, subtitle: nil, alignment: .center)
        inputTextView.setAttributedText(from: "")
        setupAddMedia()
        setupInitialView()
        setupProfileData()
        viewModel?.getTopics()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mediaCollectionView.visibleCells.forEach { cell in
            (cell as? LMFeedVideoCollectionCell)?.pauseVideo()
        }
    }
    
    open func setupAddMedia() {
        addPhotosTab.configure(with: LMStringConstants.shared.addPhotoText, image: Constants.shared.images.galleryIcon)
        addVideoTab.configure(with: LMStringConstants.shared.addVideoText, image: Constants.shared.images.videoIcon)
        addDocumentsTab.configure(with: LMStringConstants.shared.attachFiles, image: Constants.shared.images.paperclipIcon)
        addPollTab.configure(with: LMStringConstants.shared.addPoll, image: Constants.shared.images.addPollIcon, hideSeprator: true)
        taggingView.isHidden = true
    }
    
    open func setupInitialView() {
        pollPreview.isHidden = true
        linkPreview.isHidden = true
        mediaCollectionView.isHidden = true
        mediaPageControl.isHidden = true
        documentTableView.isHidden = true
        addMoreButton.isHidden = true
        topicView.isHidden = true
        createPostButton.isEnabled = false
    }
    
    open func setupProfileData() {
        headerView.configure(with: .init(profileImage: LocalPreferences.userObj?.imageUrl, username: LocalPreferences.userObj?.name ?? "User"))
    }
    
    open func observeCreateButton() {
        createPostButton.isEnabled = !mediaAttachmentData.isEmpty || !inputTextView.getText().isEmpty || !documentAttachmentData.isEmpty || isPollFlow
    }
}


// MARK: UITableView
extension LMFeedCreatePostScreen: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { documentAttachmentData.count }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMFeedCreatePostDocumentPreviewCell.self) {
            cell.configure(data: documentAttachmentData[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        documentAttachmentHeight
    }
}


// MARK: LMFeedDocumentPreviewProtocol
extension LMFeedCreatePostScreen: LMFeedDocumentPreviewProtocol {
    public func didTapCrossButton(documentID: URL) {
        viewModel?.removeAsset(url: documentID.absoluteString)
    }
    
    public func didTapDocument(documentID: URL) {
        openURL(with: documentID)
    }
}


// MARK: UICollectionView
extension LMFeedCreatePostScreen: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { mediaAttachmentData.count }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let data = mediaAttachmentData[indexPath.row] as? LMFeedImageCollectionCell.ContentModel,
           let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.imagePreview, for: indexPath) {
            cell.configure(with: data) { [weak self] imageID in
                guard let self else { return }
                viewModel?.removeAsset(url: imageID)
            }
            return cell
        } else if let data = mediaAttachmentData[indexPath.row] as? LMFeedVideoCollectionCell.ContentModel,
                  let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.videoPreview, for: indexPath) {
            cell.configure(with: data) { [weak self] videoID in
                guard let self else { return }
                viewModel?.removeAsset(url: videoID)
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: collectionView.frame.width)
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
        
        let visibleCount = mediaCollectionView.indexPathsForFullyVisibleItems()
        if visibleCount.count == 1,
           let index = visibleCount.first {
            (mediaCollectionView.cellForItem(at: index) as? LMFeedVideoCollectionCell)?.playVideo()
        }
    }
}


// MARK: LMFeedCreatePostViewModelProtocol
extension LMFeedCreatePostScreen: LMFeedCreatePostViewModelProtocol {
    public func setupLinkPreview(with data: LMFeedLinkPreview.ContentModel?) {
        linkPreview.isHidden = data == nil
        if let data {
            linkPreview.configure(with: data) { [weak self, weak linkPreview] in
                self?.viewModel?.hideLinkPreview()
                linkPreview?.isHidden = true
            }
        }
    }
    
    public func navigateToTopicView(with topics: [LMFeedTopicDataModel]) {
        do {
            let viewcontroller = try LMFeedTopicSelectionViewModel.createModule(topicEnabledState: true, isShowAllTopicsButton: false, selectedTopicIds: topics, delegate: self)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func updateTopicView(with data: LMFeedTopicView.ContentModel) {
        topicView.isHidden = false
        topicView.configure(with: data)
    }
    
    public func showMedia(documents: [LMFeedDocumentPreview.ContentModel], isShowAddMore: Bool, isShowBottomTab: Bool) {
        linkPreview.isHidden = true
        documentTableView.isHidden = documents.isEmpty
        documentAttachmentData.append(contentsOf: documents)
        documentTableView.reloadData()
        if !documents.isEmpty {
            documenTableHeight?.constant = CGFloat(documents.count) * documentAttachmentHeight
        }
        addMoreButton.isHidden = !isShowAddMore
        
        addMediaStack.isHidden = !isShowBottomTab
        observeCreateButton()
    }
    
    public func showMedia(media: [LMFeedMediaProtocol], isShowAddMore: Bool, isShowBottomTab: Bool) {
        linkPreview.isHidden = true
        mediaCollectionView.isHidden = media.isEmpty
        mediaPageControl.isHidden = media.count < 2
        mediaPageControl.numberOfPages = media.count
        mediaAttachmentData.append(contentsOf: media)
        mediaCollectionView.reloadData()
        DispatchQueue.main.async { [weak self] in
            self?.scrollingFinished()
        }
        addMoreButton.isHidden = !isShowAddMore
        addMediaStack.isHidden = !isShowBottomTab
        
        observeCreateButton()
    }
        
    public func resetMediaView() {
        pollPreview.isHidden = true
        mediaCollectionView.isHidden = true
        mediaPageControl.isHidden = true
        documentTableView.isHidden = true
        addMoreButton.isHidden = true
        mediaAttachmentData.removeAll(keepingCapacity: true)
        documentAttachmentData.removeAll(keepingCapacity: true)
    }
    
    public func openMediaPicker(_ mediaType: PostCreationAttachmentType, isFirstPick: Bool, allowedNumber: Int, selectedAssets: [PHAsset]) {
        switch mediaType {
        case .image:
            checkPhotoLibraryPermission { [weak self] in
                self?.openImagePicker(.image, isFirstTime: isFirstPick, maxSelection: allowedNumber, selectedAssets: selectedAssets)
            }
        case .video:
            checkPhotoLibraryPermission { [weak self] in
                self?.openImagePicker(.video, isFirstTime: isFirstPick, maxSelection: allowedNumber, selectedAssets: selectedAssets)
            }
        case .document:
            openDocumentPicker()
        case .none, .poll:
            break
        }
    }
    
    public func checkPhotoLibraryPermission(callback: (() -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                switch newStatus {
                case .authorized, .restricted:
                    callback?()
                default:
                    break
                }
            }
        case .denied:
            showError(with: "Please Allow Media Access.\nSettings -> Privacy -> Photos -> \(LMStringConstants.shared.appName) -> All Photos", isPopVC: false)
        default:
            callback?()
        }
    }
    
    public func navigateToCreatePoll(with data: LMFeedCreatePollDataModel?) {
        do {
            let viewcontroller = try LMFeedCreatePollViewModel.createModule(with: self, data: data)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func showPoll(poll: LMFeedCreateDisplayPollView.ContentModel) {
        isPollFlow = true
        addMediaStack.isHidden = true
        pollPreview.configure(with: poll, delegate: self)
        pollPreview.isHidden = false
        
        observeCreateButton()
    }
}


// MARK: LMFeedTaggingTextViewProtocol
extension LMFeedCreatePostScreen: LMFeedTaggingTextViewProtocol {
    public func mentionStarted(with text: String) {
        taggingView.isHidden = false
        taggingView.getUsers(for: text)
    }
    
    public func mentionStopped() {
        taggingView.stopFetchingUsers()
        taggingView.isHidden = true
    }
    
    public func contentHeightChanged() {
        let width = inputTextView.frame.size.width
        let newSize = inputTextView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        inputTextView.isScrollEnabled = newSize.height > textInputMaximumHeight
        inputTextViewHeightConstraint?.constant = min(max(newSize.height, textInputMinimumHeight), textInputMaximumHeight)
        
        viewModel?.handleLinkDetection(in: inputTextView.text)
        observeCreateButton()
    }
}


// MARK: Media Control
public extension LMFeedCreatePostScreen {
    func openImagePicker(_ mediaType: Settings.Fetch.Assets.MediaTypes, isFirstTime: Bool, maxSelection: Int, selectedAssets: [PHAsset]) {
        let imagePicker = ImagePickerController(selectedAssets: selectedAssets)
        imagePicker.settings.selection.max = maxSelection
        imagePicker.settings.fetch.assets.supportedMediaTypes = isFirstTime ? [mediaType] : [.image, .video]
        mediaCollectionView.visibleCells.forEach { cell in
            (cell as? LMFeedVideoCollectionCell)?.pauseVideo()
        }
        
        presentImagePicker(imagePicker, select: { asset in
        }, deselect: { asset in
        }, cancel: { _ in
        }, finish: { [weak self] assets in
            self?.handleMultiMedia(with: assets)
        })
    }
    
    func openDocumentPicker() {
        documentPicker.allowsMultipleSelection = true
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }
    
    func handleMultiMedia(with assets: [PHAsset]) {
        var currentAssets: [(asset: PHAsset, url: URL, data: Data)?] = Array(repeating: nil, count: assets.count)
        let dispatchGroup = DispatchGroup()
        
        let fm = FileManager.default
        
        for (index, asset) in assets.enumerated() {
            dispatchGroup.enter()
            asset.asyncURL { url in
                defer { dispatchGroup.leave() } // Ensure leave is called at the end of the closure
                
                guard let url else { return }
                
                let destination = fm.temporaryDirectory.appendingPathComponent("\(Int(Date().timeIntervalSince1970))_\(url.lastPathComponent)")
                do {
                    try fm.copyItem(at: url, to: destination)
                    let data = try Data(contentsOf: url)
                    currentAssets[index] = (asset, destination, data)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            // Remove nil values before passing to handleAssets
            let filteredAssets = currentAssets.compactMap { $0 }
            self?.viewModel?.handleAssets(assets: filteredAssets.map { ($0.asset, $0.url, $0.data) })
        }
    }
}


// MARK: UIDocumentPickerDelegate
extension LMFeedCreatePostScreen: UIDocumentPickerDelegate {
    open func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        viewModel?.handleAssets(assets: urls)
        controller.dismiss(animated: true)
    }
    
    open func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}


// MARK: LMFeedTaggedUserFoundProtocol
extension LMFeedCreatePostScreen: LMFeedTaggedUserFoundProtocol {
    public func userSelected(with route: String, and userName: String) {
        inputTextView.addTaggedUser(with: userName, route: route)
    }
    
    public func updateHeight(with height: CGFloat) {
        taggingViewHeight?.constant = height
    }
}


// MARK: LMFeedTopicViewCellProtocol
extension LMFeedCreatePostScreen: LMFeedTopicViewCellProtocol {
    public func didTapEditButton() {
        viewModel?.didTapTopicSelection()
    }
    
    public func didTapSelectTopicButton() {
        viewModel?.didTapTopicSelection()
    }
}


// MARK: LMFeedTopicSelectionViewProtocol
extension LMFeedCreatePostScreen: LMFeedTopicSelectionViewProtocol {
    public func updateTopicFeed(with topics: [LMFeedTopicDataModel]) {
        viewModel?.updateTopicFeed(with: topics)
    }
}


// MARK: LMFeedCreatePollProtocol
extension LMFeedCreatePostScreen: LMFeedCreatePollProtocol {
    public func cancelledPollCreation() {
        viewModel?.updateCurrentSelection(to: .none)
    }
    
    public func updatePollDetails(with data: LMFeedCreatePollDataModel) {
        viewModel?.updatePollPreview(with: data)
    }
}


// MARK: LMFeedCreatePollViewProtocol
extension LMFeedCreatePostScreen: LMFeedCreatePollViewProtocol {
    public func onTapCrossButton() {
        isPollFlow = false
        viewModel?.removePoll()
    }
    
    public func onTapEditButton() {
        viewModel?.editPoll()
    }
}
