import UIKit
import LikeMindsFeedUI

open class LMFeedVideoListScreen: LMFeedViewController {
    // MARK: UI Elements
    open private(set) lazy var videoCollectionView: LMFeedCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collection = LMFeedCollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .black
        collection.delegate = self
        collection.dataSource = self
        collection.prefetchDataSource = self
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        return collection
    }()
    
    // MARK: Data Variables
    public var viewModel: LMFeedVideoListViewModel?
    public weak var delegate: LMFeedPostListVCFromProtocol?
    
    // MARK: Data Variables
    public var data: [LMFeedPostContentModel] = [] {
        didSet {
            print(data.count)
        }
    }
    // MARK: Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        setupActions()
        setupAppearance()
        
        viewModel?.getFeed(fetchInitialPage: true)
    }
    
    open override func setupObservers() {
        super.setupObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostEdited, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .LMPostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postDelete), name: .LMPostDeleted, object: nil)
    }
    
    @objc open func postUpdated(notification: Notification) {
        if let data = notification.object as? LMFeedPostDataModel {
            viewModel?.updatePostData(for: data)
        }
    }
    
    @objc open func postDelete(notification: Notification) {
        if let postID = notification.object as? String {
            viewModel?.removePost(for: postID)
        }
    }
    
    public func updatePostList(with post: [LMFeedPostContentModel], isInitialPage: Bool) {
        
        if isInitialPage {
            data.removeAll(keepingCapacity: true)
        }
        
        let oldIndex = data.count
        data.append(contentsOf: post)
        let newIndex = data.count - 1
        
        if data.isEmpty {
            configureEmptyListView()
        } else {
            videoCollectionView.backgroundView = nil
        }
        
        if isInitialPage {
            videoCollectionView.reloadData()
        } else {
            videoCollectionView.performBatchUpdates({
                let indexSet = IndexSet(integersIn: oldIndex...newIndex)
                videoCollectionView.insertSections(indexSet)
            })
        }
        
        delegate?.onPostDataFetched(isEmpty: data.isEmpty)
    }
    
    
    public func updatePost(with post: LMFeedPostContentModel, onlyHeader: Bool, onlyFooter: Bool) {
        guard let index = data.firstIndex(where: { $0.postID == post.postID }) else { return }
        
        data[index] = post
        
        if onlyHeader {
            if let cell = videoCollectionView.cellForItem(at: IndexPath(item: index, section: 0)),
               let header = cell.contentView.subviews.first(where: { $0 is LMFeedPostHeaderView }) as? LMFeedPostHeaderView {
                header.togglePinStatus(isPinned: post.headerData.isPinned)
            }
        } else if onlyFooter {
            if let cell = videoCollectionView.cellForItem(at: IndexPath(item: index, section: 0)),
               let footer = cell.contentView.subviews.first(where: { $0 is LMFeedBasePostFooterView }) as? LMFeedBasePostFooterView {
                footer.configure(with: post.footerData, topResponse: post.topResponse, postID: post.postID, delegate: self, orientation: .vertical)
            }
        } else {
            videoCollectionView.performBatchUpdates({
                videoCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            })
        }
    }
    
    // MARK: Setup Methods
    open override func setupViews() {
        super.setupViews()
        view.addSubview(videoCollectionView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        view.pinSubView(subView: videoCollectionView)
    }
    
    open override func setupActions() {
        super.setupActions()
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = .black
    }
    
    // MARK: Helper Methods
    open func reloadCollectionView() {
        videoCollectionView.reloadData()
    }
    
    open func configureEmptyListView() {
        let emptyView = LMFeedNoPostWidget(frame: .zero)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.configure(title: LMStringConstants.shared.newPost) { [weak self] in
            do {
                let viewcontroller = try LMFeedCreatePostViewModel.createModule(showHeading: false)
                self?.navigationController?.pushViewController(viewcontroller, animated: true)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        videoCollectionView.backgroundView = emptyView
        emptyView.setHeightConstraint(with: videoCollectionView.heightAnchor)
        emptyView.setWidthConstraint(with: videoCollectionView.widthAnchor)
    }
    
    // Add this method to handle video playback
    private func handleVideoPlayback() {
        // Get the current visible cell
        let visibleRect = CGRect(origin: videoCollectionView.contentOffset, size: videoCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        if let visibleIndexPath = videoCollectionView.indexPathForItem(at: visiblePoint),
           let cell = videoCollectionView.cellForItem(at: visibleIndexPath) {
            // Find the video cell in the content view
            if let videoCell = cell.contentView.subviews.first(where: { $0 is LMFeedVideoCollectionCell }) as? LMFeedVideoCollectionCell {
                // Pause all other video cells
                videoCollectionView.visibleCells.forEach { cell in
                    if let videoCell = cell.contentView.subviews.first(where: { $0 is LMFeedVideoCollectionCell }) as? LMFeedVideoCollectionCell {
                        videoCell.pauseVideo()
                    }
                }
                // Play the visible video cell
                videoCell.playVideo()
            }
        }
    }
    
    // Modify scroll handling methods
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Pause all visible videos when scrolling starts
        videoCollectionView.visibleCells.forEach { cell in
            if let videoCell = cell.contentView.subviews.first(where: { $0 is LMFeedVideoCollectionCell }) as? LMFeedVideoCollectionCell {
                videoCell.pauseVideo()
            }
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.y / scrollView.frame.height)
        if page >= data.count - 1 {
            viewModel?.getFeed()
        }
        // Handle video playback when scrolling stops
        handleVideoPlayback()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // Handle video playback when scrolling stops without deceleration
            handleVideoPlayback()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Start playing the visible video when view appears
        handleVideoPlayback()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause all videos when view disappears
        videoCollectionView.visibleCells.forEach { cell in
            if let videoCell = cell.contentView.subviews.first(where: { $0 is LMFeedVideoCollectionCell }) as? LMFeedVideoCollectionCell {
                videoCell.pauseVideo()
            }
        }
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching
extension LMFeedVideoListScreen: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count + 1 // Add 1 for the caught up view
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        // Remove any existing subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // If this is the last cell, show the caught up view
        if indexPath.item == data.count {
            configureCaughtUpCell(cell)
            return cell
        }
        
        if let postData = data[safe: indexPath.item] {
            cell.backgroundColor = .black
            
            // Add video preview cell as background
            let videoCell = LMUIComponents.shared.videoPreview.init()
            videoCell.translatesAutoresizingMaskIntoConstraints = false
            videoCell.containerView.backgroundColor = .clear
            
            cell.contentView.addSubview(videoCell)
            NSLayoutConstraint.activate([
                videoCell.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                videoCell.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                videoCell.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                videoCell.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])

            // Configure video cell with auto-play disabled initially
            if let videoData = postData.mediaData.first as? LMFeedVideoCollectionCell.ContentModel {
                videoCell.configure(with: videoData, index: indexPath.row, showVolumeButton: false)
                // Initially pause the video
                videoCell.pauseVideo()
            }
            
            let textCell = LMUIComponents.shared.videoTextCell.init()
            textCell.translatesAutoresizingMaskIntoConstraints = false
            textCell.containerView.backgroundColor = .clear
            textCell.configure(data: postData)
            
            cell.contentView.addSubview(textCell)
            NSLayoutConstraint.activate([
                textCell.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                textCell.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -40),
                textCell.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
                textCell.widthAnchor.constraint(equalToConstant: 300),
            ])

            // Configure header
            let header = LMFeedPostHeaderView()
            header.translatesAutoresizingMaskIntoConstraints = false
            header.containerBackgroundColor = .clear
            
            cell.contentView.addSubview(header)
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                header.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -88),
                header.bottomAnchor.constraint(equalTo: textCell.topAnchor, constant: -8),
                header.heightAnchor.constraint(equalToConstant: 60)
            ])

            // Add footer on the right side
            let footer = LMUIComponents.shared.videoFooterView.init()
            footer.translatesAutoresizingMaskIntoConstraints = false
            footer.containerBackgroundColor = .clear
            
            cell.contentView.addSubview(footer)
            NSLayoutConstraint.activate([
                footer.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                footer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16),
                footer.widthAnchor.constraint(equalToConstant: 60),
                footer.heightAnchor.constraint(equalToConstant: 220)
            ])
            
            // Configure header
            header.configure(with: postData.headerData, postID: postData.postID, userUUID: postData.userUUID, delegate: self)
            header.authorNameLabel.textColor = .white
            header.subTitleLabel.textColor = .white
            header.menuButton.isHidden = true
            
            // Configure footer
            footer.configure(with: postData.footerData, topResponse: postData.topResponse, postID: postData.postID, delegate: self, orientation: .vertical)
        }
        
        return cell
    }
    
    private func configureCaughtUpCell(_ cell: UICollectionViewCell) {
        cell.backgroundColor = .white
        
        let caughtUpView = UIView()
        caughtUpView.translatesAutoresizingMaskIntoConstraints = false
        caughtUpView.backgroundColor = .white
        
        // Add checkmark icon in circle
        let checkmarkImageView = UIImageView()
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.tintColor = .systemGreen
        
        // Create circle background for checkmark
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        circleView.layer.cornerRadius = 30 // Will be set to half of width/height
        
        // Configure checkmark image
        if let checkmarkImage = UIImage(systemName: "checkmark.circle.fill") {
            checkmarkImageView.image = checkmarkImage
        }
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = LMStringConstants.shared.videoListEndPageTitle
        messageLabel.textColor = .black
        messageLabel.font = .systemFont(ofSize: 18, weight: .medium)
        messageLabel.textAlignment = .center
        
        let viewOldPostsButton = UIButton(type: .system)
        viewOldPostsButton.translatesAutoresizingMaskIntoConstraints = false
        viewOldPostsButton.setTitle(LMStringConstants.shared.videoListEndPageButtonTitle, for: .normal)
        viewOldPostsButton.setTitleColor(.systemBlue, for: .normal)
        viewOldPostsButton.titleLabel?.font = .systemFont(ofSize: 16)
        viewOldPostsButton.backgroundColor = .clear
        viewOldPostsButton.addTarget(self, action: #selector(didTapViewOldPosts), for: .touchUpInside)
        
        caughtUpView.addSubview(circleView)
        circleView.addSubview(checkmarkImageView)
        caughtUpView.addSubview(messageLabel)
        caughtUpView.addSubview(viewOldPostsButton)
        
        cell.contentView.addSubview(caughtUpView)
        
        NSLayoutConstraint.activate([
            caughtUpView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            caughtUpView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            caughtUpView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            caughtUpView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            
            // Circle view constraints
            circleView.centerXAnchor.constraint(equalTo: caughtUpView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: caughtUpView.centerYAnchor, constant: -60),
            circleView.widthAnchor.constraint(equalToConstant: 60),
            circleView.heightAnchor.constraint(equalToConstant: 60),
            
            // Checkmark image constraints
            checkmarkImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 40),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 40),
            
            messageLabel.centerXAnchor.constraint(equalTo: caughtUpView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 16),
            
            viewOldPostsButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            viewOldPostsButton.centerXAnchor.constraint(equalTo: caughtUpView.centerXAnchor),
            viewOldPostsButton.widthAnchor.constraint(equalToConstant: 150),
            viewOldPostsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func didTapViewOldPosts() {
        // Clear existing posts
        data.removeAll()
        videoCollectionView.reloadData()
        // Get fresh posts from page 1
        viewModel?.getFeed(fetchInitialPage: true)
    }
    
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let filtered = indexPaths.filter({ $0.item >= data.count - 1 })
        
        if !filtered.isEmpty {
            viewModel?.getFeed()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension LMFeedVideoListScreen: UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: LMFeedVideoListViewModelProtocol
extension LMFeedVideoListScreen: LMFeedVideoListViewModelProtocol {
    public func showActivityLoader() {
        // Handle loading state
    }
    
    public func showHideFooterLoader(isShow: Bool) {
        // Handle footer loading state
    }
    
    public func updateVideoList(with posts: [LMFeedPostContentModel], isInitialPage: Bool) {
        if isInitialPage {
            data.removeAll(keepingCapacity: true)
        }
        
        let oldIndex = data.count
        data.append(contentsOf: posts)
        let newIndex = data.count - 1
        
        if data.isEmpty {
            configureEmptyListView()
        } else {
            videoCollectionView.backgroundView = nil
        }
        
        if isInitialPage {
            videoCollectionView.reloadData()
        } else {
            videoCollectionView.performBatchUpdates({
                let indexSet = IndexSet(integersIn: oldIndex...newIndex)
                videoCollectionView.insertSections(indexSet)
            })
        }
        
        delegate?.onPostDataFetched(isEmpty: data.isEmpty)
    }
    
    public override func presentAlert(with alert: UIAlertController, animated: Bool) {
        present(alert, animated: animated)
    }
    public func removePost(with postID: String) {
        guard let index = data.firstIndex(where: { $0.postID == postID }) else { return }
        
        data.remove(at: index)
        
        videoCollectionView.performBatchUpdates({
            videoCollectionView.deleteSections(IndexSet(integer: index))
        })
    }
    
    public func navigateToReportScreen(for postID: String, creatorUUID: String) {
        do {
            let viewcontroller = try LMFeedReportViewModel.createModule(creatorUUID: creatorUUID, postID: postID)
            
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func navigateToDeleteScreen(for postID: String) {
        guard let viewcontroller = LMFeedDeleteViewModel.createModule(postID: postID) else { return }
        viewcontroller.modalPresentationStyle = .overFullScreen
        present(viewcontroller, animated: false)
    }
    
    public func navigateToEditScreen(for postID: String) {
        guard let viewcontroller = LMFeedEditShortVideoViewModel.createModule(for: postID) else { return }
        navigationController?.pushViewController(viewcontroller, animated: true)
    }
}

// MARK: LMFeedPostHeaderViewProtocol, LMFeedPostFooterViewProtocol
extension LMFeedVideoListScreen: LMFeedPostHeaderViewProtocol, LMFeedVideoFooterViewProtocol {
    public func didTapFooterMenuButton(for postID: String) {
        viewModel?.showMenu(for: postID)
    }
    
    
    public func didTapPost(postID: String) {
    
    }
    
    public func didTapProfilePicture(having uuid: String) {
        showError(with: "Tapped User Profile having uuid: \(uuid)", isPopVC: false)
    }
    
    public func didTapPostMenuButton(for postID: String) {
       //
    }
    
    
    public func didTapSaveButton(for postID: String) {
        viewModel?.savePost(for: postID)
    }
    
    public func didTapLikeButton(for postID: String) {
        if let index = data.firstIndex(where: { $0.postID == postID }) {
            data[index].footerData.isLiked.toggle()
            let isLiked = data[index].footerData.isLiked
            data[index].footerData.likeCount += isLiked ? 1 : -1
            viewModel?.likePost(for: postID)
        }
    }
    
    
    
    
    public func didTapLikeTextButton(for postID: String) {
        guard viewModel?.allowPostLikeView(for: postID) == true else { return }
        let bottomSheet = LMFeedLikeBottomsheet(postID: postID)
        bottomSheet.modalPresentationStyle = .pageSheet
        present(bottomSheet, animated: true)
    }
    
    public func didTapCommentButton(for postID: String) {
        let postDetailViewModel = LMFeedPostDetailViewModel(postID: postID, delegate: nil, openCommentSection: false, scrollToCommentSection: false)
        let bottomSheet = LMFeedCommentBottomsheet(postID: postID, viewModel: postDetailViewModel)
        bottomSheet.modalPresentationStyle = .pageSheet
        present(bottomSheet, animated: true)
    }
    
    public func didTapShareButton(for postID: String) {
        LMFeedShareUtility.sharePost(from: self, postID: postID)
    }
    
    
}
