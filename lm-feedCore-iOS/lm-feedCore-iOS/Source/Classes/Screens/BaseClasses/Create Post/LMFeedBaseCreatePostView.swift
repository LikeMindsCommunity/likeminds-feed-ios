//
//  LMFeedBaseCreatePostView.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 24/07/24.
//

import LikeMindsFeedUI
import UIKit
import AVKit

open class LMFeedBaseCreatePostView: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
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
        textView.dataDetectorTypes = [.link]
        textView.mentionDelegate = self
        textView.backgroundColor = LMFeedAppearance.shared.colors.clear
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.placeHolderText = "Write Something here..."
        textView.backgroundColor = LMFeedAppearance.shared.colors.clear
        textView.addDoneButtonOnKeyboard()
        return textView
    }()
    
    open private(set) lazy var linkPreview: LMFeedLinkPreview = {
        let view = LMUIComponents.shared.linkPreview.init().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
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
//        collection.dataSource = self
//        collection.delegate = self
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
//        table.dataSource = self
//        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = LMFeedAppearance.shared.colors.clear
        return table
    }()
    
    open private(set) lazy var addMoreButton: LMButton = {
        let button = LMButton.createButton(with: LMStringConstants.shared.addMoreText, image: LMFeedConstants.shared.images.plusIcon, textColor: LMFeedAppearance.shared.colors.appTintColor, textFont: LMFeedAppearance.shared.fonts.buttonFont1, contentSpacing: .init(top: 8, left: 16, bottom: 8, right: 16))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = LMFeedAppearance.shared.colors.appTintColor
        button.layer.borderColor = LMFeedAppearance.shared.colors.appTintColor.cgColor
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
        button.tintColor = LMFeedAppearance.shared.colors.appTintColor
        return button
    }()
    
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
    
    
    // MARK: Data Variables
    public var mediaAttachmentData: [LMFeedMediaProtocol] = []
    
    public func setupTableView() { }
    
    @objc
    open func didTapCreateButton() { }
}


// MARK: LMFeedTopicViewCellProtocol
@objc
extension LMFeedBaseCreatePostView: LMFeedTopicViewCellProtocol {
    public func didTapEditButton() { }
    
    public func didTapSelectTopicButton() { }
}


// MARK: LMFeedTaggedUserFoundProtocol
@objc
extension LMFeedBaseCreatePostView: LMFeedTaggedUserFoundProtocol {
    public func userSelected(with route: String, and userName: String) { }
    
    public func updateHeight(with height: CGFloat) { }
}


// MARK: LMFeedTaggingTextViewProtocol
@objc
extension LMFeedBaseCreatePostView: LMFeedTaggingTextViewProtocol {
    public func mentionStarted(with text: String) { }
    
    public func mentionStopped() { }
}


// MARK: UIDocumentPickerDelegate
extension LMFeedBaseCreatePostView: UIDocumentPickerDelegate {
    open func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    }
    
    open func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    
    }
}
