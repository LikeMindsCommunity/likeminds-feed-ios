import AVKit
import LikeMindsFeedUI
import UIKit

@IBDesignable
open class LMFeedEditShortVideoScreen: LMFeedViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
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
    
    open private(set) lazy var scrollStackView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
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
    
    open private(set) lazy var inputTextView: LMFeedTaggingTextView = {
        let textView = LMFeedTaggingTextView().translatesAutoresizingMaskIntoConstraints()
        textView.mentionDelegate = self
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.placeHolderText = "Write something here..."
        textView.addDoneButtonOnKeyboard()
        return textView
    }()
    
    open private(set) lazy var mediaCollectionView: LMFeedCollectionView = {
        let collection = LMFeedCollectionView(frame: .zero, collectionViewLayout: LMFeedCollectionView.mediaFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
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
    
    open private(set) lazy var saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
    
    // MARK: Data Variables
    public var viewmodel: LMFeedEditShortVideoViewModel?
    public var mediaCells: [LMFeedVideoCollectionCell.ContentModel] = []
    public var inputTextViewHeightConstraint: NSLayoutConstraint?
    public var textInputMaximumHeight: CGFloat = 150
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        containerView.addSubview(scrollView)
        scrollView.addSubview(scrollStackView)
        
        [headerView, inputTextView, mediaCollectionView, mediaPageControl].forEach { subview in
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
        
        scrollView.setWidthConstraint(with: containerView.widthAnchor)
        scrollStackView.setWidthConstraint(with: containerView.widthAnchor)
        mediaCollectionView.setHeightConstraint(with: mediaCollectionView.widthAnchor)
        
        [headerView, inputTextView, mediaCollectionView, mediaPageControl].forEach { subView in
            NSLayoutConstraint.activate([
                subView.leadingAnchor.constraint(equalTo: scrollStackView.leadingAnchor, constant: 16),
                subView.trailingAnchor.constraint(equalTo: scrollStackView.trailingAnchor, constant: -16)
            ])
        }
    }
    
    open override func setupActions() {
        super.setupActions()
        
        saveButton.tintColor = LMFeedAppearance.shared.colors.appTintColor
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc
    open func didTapSaveButton() {
        viewmodel?.updateVideo(with: inputTextView.getText())
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isTranslucent = false
        
        setupInitialView()
        setNavigationTitleAndSubtitle(with: LMStringConstants.shared.editVideoPost, subtitle: nil, alignment: .center)
        viewmodel?.getInitalData()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mediaCollectionView.visibleCells.forEach { cell in
            (cell as? LMFeedVideoCollectionCell)?.pauseVideo()
        }
    }
    
    open func setupInitialView() {
        mediaCollectionView.isHidden = true
        mediaPageControl.isHidden = true
    }
}

// MARK: UICollectionView
extension LMFeedEditShortVideoScreen: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mediaCells.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let data = mediaCells[safe: indexPath.row],
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

// MARK: LMFeedTaggingTextViewProtocol
@objc
extension LMFeedEditShortVideoScreen: LMFeedTaggingTextViewProtocol {
    open func mentionStarted(with text: String) {
        // Handle mention started if needed
    }
    
    open func mentionStopped() {
        // Handle mention stopped if needed
    }
    
    open func contentHeightChanged() {
        let width = inputTextView.frame.size.width
        let newSize = inputTextView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        
        inputTextView.isScrollEnabled = newSize.height > textInputMaximumHeight
        inputTextViewHeightConstraint?.constant = min(max(newSize.height, 80), textInputMaximumHeight)
        
        observeSaveButton()
    }
    
    public func observeSaveButton() {
        saveButton.isEnabled = !inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: LMFeedEditShortVideoViewModelProtocol
extension LMFeedEditShortVideoScreen: LMFeedEditShortVideoViewModelProtocol {
    public func setupData(with userData: LMFeedCreatePostHeaderView.ContentModel, text: String) {
        headerView.configure(with: userData)
        inputTextView.setAttributedText(from: text, prefix: "@")
        contentHeightChanged()
    }
    
    public func setupMediaPreview(with mediaCells: [LMFeedVideoCollectionCell.ContentModel]) {
        self.mediaCells = mediaCells
        
        if !mediaCells.isEmpty {
            mediaCollectionView.isHidden = false
            UIView.performWithoutAnimation {
                mediaCollectionView.reloadData()
            }
            scrollingFinished()
            mediaPageControl.isHidden = false
            mediaPageControl.numberOfPages = mediaCells.count
            mediaPageControl.currentPage = 0
        }
    }
} 
