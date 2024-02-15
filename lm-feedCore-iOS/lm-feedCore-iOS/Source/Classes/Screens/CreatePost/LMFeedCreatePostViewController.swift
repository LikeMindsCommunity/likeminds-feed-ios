//
//  LMFeedCreatePostViewController.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 16/01/24.
//

import AVKit
import BSImagePicker
import lm_feedUI_iOS
import UIKit
import Photos

@IBDesignable
open class LMFeedCreatePostViewController: LMViewController {
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
        let view = LMUIComponents.shared.topicFeed.init().translatesAutoresizingMaskIntoConstraints()
        view.delegate = self
        return view
    }()
    
    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView().translatesAutoresizingMaskIntoConstraints()
        textView.dataDetectorTypes = [.link]
        textView.mentionDelegate = self
        textView.backgroundColor = Appearance.shared.colors.clear
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
    
    open private(set) lazy var addMoreButton: LMButton = {
        let button = LMButton.createButton(with: "Add More", image: Constants.shared.images.plusIcon, textColor: Appearance.shared.colors.appTintColor, textFont: Appearance.shared.fonts.buttonFont1, contentSpacing: .init(top: 4, left: 8, bottom: 4, right: 8))
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
    
    open private(set) lazy var addPhotosTab: LMFeedCreatePostAddMediaView = {
        let view = LMUIComponents.shared.createPostAddMediaView.init().translatesAutoresizingMaskIntoConstraints()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var addVideoTab: LMFeedCreatePostAddMediaView = {
        let view = LMUIComponents.shared.createPostAddMediaView.init().translatesAutoresizingMaskIntoConstraints()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var addDocumentsTab: LMFeedCreatePostAddMediaView = {
        let view = LMUIComponents.shared.createPostAddMediaView.init().translatesAutoresizingMaskIntoConstraints()
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
        let button = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(didTapCreateButton))
        button.tintColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    
    // MARK: Data Variables
    public var viewModel: LMFeedCreatePostViewModel?
    public var documentCellData: [LMFeedDocumentPreview.ViewModel] = []
    public var documenTableHeight: NSLayoutConstraint?
    
    public var taggingViewHeight: NSLayoutConstraint?
    public var inputTextViewHeightConstraint: NSLayoutConstraint?
    public var textInputMaximumHeight: CGFloat = 150
    
    public var mediaCellData: [LMFeedMediaProtocol] = []
    
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
        
        [headerView, topicView, inputTextView, linkPreview, mediaCollectionView, documentTableView, addMoreButton].forEach { subView in
            scrollStackView.addArrangedSubview(subView)
        }
        
        [addPhotosTab, addVideoTab, addDocumentsTab].forEach { subView in
            addMediaStack.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.pinSubView(subView: containerView)
        
        containerView.addConstraint(top: (view.safeAreaLayoutGuide.topAnchor, 0),
                                    bottom: (view.safeAreaLayoutGuide.bottomAnchor, 0),
                                    leading: (view.safeAreaLayoutGuide.leadingAnchor, 0),
                                    trailing: (view.safeAreaLayoutGuide.trailingAnchor, 0))
        
        containerView.pinSubView(subView: containerStackView)
        scrollView.pinSubView(subView: scrollStackView)
        headerView.setHeightConstraint(with: 64)
        topicView.setHeightConstraint(with: 2, priority: .defaultLow)
        linkPreview.setHeightConstraint(with: 1000, priority: .defaultLow)
        addPhotosTab.setHeightConstraint(with: 40)
        scrollStackView.setHeightConstraint(with: 1000, priority: .defaultLow)
        
        taggingView.addConstraint(top: (inputTextView.bottomAnchor, 0),
                                  leading: (inputTextView.leadingAnchor, 0),
                                  trailing: (inputTextView.trailingAnchor, 0))
        taggingView.bottomAnchor.constraint(lessThanOrEqualTo: scrollStackView.bottomAnchor, constant: -16).isActive = true
        taggingViewHeight = taggingView.setHeightConstraint(with: 10)
        
        inputTextViewHeightConstraint = inputTextView.setHeightConstraint(with: 40)
        
        documenTableHeight = documentTableView.setHeightConstraint(with: Constants.shared.number.documentPreviewSize)
        
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor),
            scrollStackView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor),
            mediaCollectionView.heightAnchor.constraint(equalTo: mediaCollectionView.widthAnchor)
        ])
        
        scrollStackView.subviews.forEach { subView in
            if subView != addMoreButton {
                NSLayoutConstraint.activate([
                    subView.leadingAnchor.constraint(equalTo: scrollStackView.leadingAnchor, constant: 16),
                    subView.trailingAnchor.constraint(equalTo: scrollStackView.trailingAnchor, constant: -16)
                ])
            }
        }
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
    }
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        addPhotosTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddPhoto)))
        addVideoTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddVideo)))
        addDocumentsTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddDocument)))
        addMoreButton.addTarget(self, action: #selector(didTapAddMoreButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = createPostButton
    }
    
    @objc
    open func didTapAddPhoto() {
        LMFeedMain.analytics?.trackEvent(for: .postCreationAttachmentClicked, eventProperties: ["type": "image"])
        viewModel?.updateCurrentSelection(to: .image)
    }
    
    @objc
    open func didTapAddVideo() {
        LMFeedMain.analytics?.trackEvent(for: .postCreationAttachmentClicked, eventProperties: ["type": "video"])
        viewModel?.updateCurrentSelection(to: .video)
    }
    
    @objc
    open func didTapAddDocument() {
        LMFeedMain.analytics?.trackEvent(for: .postCreationAttachmentClicked, eventProperties: ["type": "file"])
        viewModel?.updateCurrentSelection(to: .document)
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
        setNavigationTitleAndSubtitle(with: "Create a Post", subtitle: nil)
        inputTextView.setAttributedText(from: "")
        setupAddMedia()
        setupInitialView()
        setupProfileData()
        viewModel?.getTopics()
    }
    
    open func setupAddMedia() {
        addPhotosTab.configure(with: "Add Photo", image: Constants.shared.images.galleryIcon.withTintColor(.orange))
        addVideoTab.configure(with: "Add Video", image: Constants.shared.images.videoIcon)
        addDocumentsTab.configure(with: "Attach Files", image: Constants.shared.images.paperclipIcon)
        taggingView.isHidden = true
    }
    
    open func setupInitialView() {
        linkPreview.isHidden = true
        mediaCollectionView.isHidden = true
        documentTableView.isHidden = true
        addMoreButton.isHidden = true
        topicView.isHidden = true
        createPostButton.isEnabled = false
    }
    
    open func setupProfileData() {
        guard let user = LocalPreferences.userObj else {
            headerView.configure(with: .init(profileImage: nil, username: "user_name"))
            return
        }
        headerView.configure(with: .init(profileImage: user.imageUrl, username: user.name ?? "user_name"))
    }
    
    open func observeCreateButton() {
        createPostButton.isEnabled = !mediaCellData.isEmpty || !inputTextView.getText().isEmpty || !documentCellData.isEmpty
    }
}


// MARK: UITableView
extension LMFeedCreatePostViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { documentCellData.count }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMFeedCreatePostDocumentPreviewCell.self) {
            cell.configure(data: documentCellData[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
}


// MARK: LMFeedDocumentPreviewProtocol
extension LMFeedCreatePostViewController: LMFeedDocumentPreviewProtocol {
    public func didTapCrossButton(documentID: String) {
        viewModel?.removeAsset(url: documentID)
    }
    
    public func didTapDocument(documentID: String) { }
}


// MARK: UICollectionView
extension LMFeedCreatePostViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { mediaCellData.count }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.imagePreviewCell, for: indexPath),
           let data = mediaCellData[indexPath.row] as? LMFeedImageCollectionCell.ViewModel {
            cell.configure(with: data) { [weak self] imageID in
                guard let self else { return }
                viewModel?.removeAsset(url: imageID)
            }
            return cell
        } else if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.videoPreviewCell, for: indexPath),
                  let data = mediaCellData[indexPath.row] as? LMFeedVideoCollectionCell.ViewModel {
            cell.configure(with: data, videoPlayer: videoPlayer) { [weak self] videoID in
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
}


// MARK: LMFeedCreatePostViewModelProtocol
extension LMFeedCreatePostViewController: LMFeedCreatePostViewModelProtocol {
    public func setupLinkPreview(with data: LMFeedLinkPreview.ViewModel?) {
        linkPreview.isHidden = data == nil
        if let data {
            linkPreview.configure(with: data) { [weak self] in
                self?.viewModel?.hideLinkPreview()
                self?.linkPreview.isHidden = true
            }
        }
    }
    
    public func navigateToTopicView(with topics: [String]) {
        do {
            let viewcontroller = try LMFeedTopicSelectionViewModel.createModule(topicEnabledState: true, isShowAllTopicsButton: false, selectedTopicIds: topics, delegate: self)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func updateTopicView(with data: LMFeedTopicView.ViewModel) {
        topicView.isHidden = false
        topicView.configure(with: data)
    }
    
    public func showMedia(documents: [LMFeedDocumentPreview.ViewModel], isShowAddMore: Bool, isShowBottomTab: Bool) {
        linkPreview.isHidden = true
        documentTableView.isHidden = documents.isEmpty
        documentCellData.append(contentsOf: documents)
        documentTableView.reloadData()
        documenTableHeight?.constant = documentTableView.tableViewHeight
        addMoreButton.isHidden = !isShowAddMore
        
        addMediaStack.isHidden = !isShowBottomTab
        observeCreateButton()
    }
    
    public func showMedia(media: [LMFeedMediaProtocol], isShowAddMore: Bool, isShowBottomTab: Bool) {
        linkPreview.isHidden = true
        mediaCollectionView.isHidden = media.isEmpty
        mediaCellData.append(contentsOf: media)
        mediaCollectionView.reloadData()
        addMoreButton.isHidden = !isShowAddMore
        addMediaStack.isHidden = !isShowBottomTab
        
        observeCreateButton()
    }
    
    public func resetMediaView() {
        mediaCollectionView.isHidden = true
        documentTableView.isHidden = true
        addMoreButton.isHidden = true
        mediaCellData.removeAll(keepingCapacity: true)
        documentCellData.removeAll(keepingCapacity: true)
    }
    
    public func showAddMediaView() {
        
    }
    
    public func openMediaPicker(_ mediaType: PostCreationAttachmentType, isFirstPick: Bool, allowedNumber: Int) {
        switch mediaType {
        case .image:
            openImagePicker(.image, isFirstTime: isFirstPick, maxSelection: allowedNumber)
        case .video:
            openImagePicker(.video, isFirstTime: isFirstPick, maxSelection: allowedNumber)
        case .document:
            openDocumentPicker()
        case .none:
            break
        }
    }
}


// MARK: LMFeedTaggingTextViewProtocol
extension LMFeedCreatePostViewController: LMFeedTaggingTextViewProtocol {
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
        inputTextViewHeightConstraint?.constant = min(newSize.height, textInputMaximumHeight)
        
        viewModel?.handleLinkDetection(in: inputTextView.text)
        observeCreateButton()
    }
}


// MARK: Media Control
public extension LMFeedCreatePostViewController {
    func openImagePicker(_ mediaType: Settings.Fetch.Assets.MediaTypes, isFirstTime: Bool, maxSelection: Int) {
        var currentAssets: [(asset: PHAsset, url: URL)] = []
        
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = maxSelection
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = isFirstTime ? [mediaType] : [.image, .video]
        imagePicker.settings.selection.unselectOnReachingMax = false
        
        presentImagePicker(imagePicker, select: { asset in
            asset.asyncURL { url in
                guard let url else { return }
                currentAssets.append((asset, url))
            }
        }, deselect: { asset in
            asset.asyncURL { _ in
                currentAssets.removeAll(where: { $0.asset == asset })
            }
        }, cancel: { _ in
        }, finish: { [weak self] assets in
            self?.viewModel?.handleAssets(assets: currentAssets)
        })
    }
    
    func openDocumentPicker() {
        documentPicker.allowsMultipleSelection = true
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }
}


// MARK: UIDocumentPickerDelegate
extension LMFeedCreatePostViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        viewModel?.handleAssets(assets: urls)
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}


// MARK: LMFeedTaggedUserFoundProtocol
extension LMFeedCreatePostViewController: LMFeedTaggedUserFoundProtocol {
    public func userSelected(with route: String, and userName: String) {
        inputTextView.addTaggedUser(with: userName, route: route)
    }
    
    public func updateHeight(with height: CGFloat) {
        taggingViewHeight?.constant = height
    }
}


// MARK: LMFeedTopicViewCellProtocol
extension LMFeedCreatePostViewController: LMFeedTopicViewCellProtocol {
    public func didTapEditButton() {
        viewModel?.didTapTopicSelection()
    }
    
    public func didTapSelectTopicButton() {
        viewModel?.didTapTopicSelection()
    }
}


// MARK: LMFeedTopicSelectionViewProtocol
extension LMFeedCreatePostViewController: LMFeedTopicSelectionViewProtocol {
    public func updateTopicFeed(with topics: [(topicName: String, topicID: String)]) {
        viewModel?.updateTopicFeed(with: topics)
    }
}
