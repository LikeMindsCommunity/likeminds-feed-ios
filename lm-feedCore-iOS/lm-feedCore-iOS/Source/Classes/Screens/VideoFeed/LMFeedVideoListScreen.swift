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
        
        viewModel?.getFeed()
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
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching
extension LMFeedVideoListScreen: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        // Remove any existing subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        if let postData = data[safe: indexPath.item] {
            cell.backgroundColor = .black
            
            // Add text cell first (bottom element)
            let textCell = LMUIComponents.shared.textCell.init()
            textCell.translatesAutoresizingMaskIntoConstraints = false
            textCell.backgroundColor = .clear
            textCell.contentView.backgroundColor = .clear
            textCell.backgroundView = nil
            textCell.containerView.backgroundColor = .clear
            textCell.configure(data: postData)
            
            cell.contentView.addSubview(textCell)
            NSLayoutConstraint.activate([
                textCell.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                textCell.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -80),
                textCell.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -60),
                textCell.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
            ])

            // Add topic cell above text cell
            let topicCell = LMUIComponents.shared.topicCell.init()
            topicCell.translatesAutoresizingMaskIntoConstraints = false
            topicCell.backgroundColor = .clear
            topicCell.contentView.backgroundColor = .clear
            topicCell.backgroundView = nil
            topicCell.containerView.backgroundColor = .clear
            
            cell.contentView.addSubview(topicCell)
            NSLayoutConstraint.activate([
                topicCell.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                topicCell.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -88),
                topicCell.bottomAnchor.constraint(equalTo: textCell.topAnchor, constant: -8),
                topicCell.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            topicCell.configure(data: postData)

            // Add header above topic cell
            let header = LMFeedPostHeaderView()
            header.translatesAutoresizingMaskIntoConstraints = false
            header.backgroundColor = .clear
            header.contentView.backgroundColor = .clear
            header.backgroundView = nil
            header.containerBackgroundColor = .clear
            
            cell.contentView.addSubview(header)
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                header.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -88),
                header.bottomAnchor.constraint(equalTo: topicCell.topAnchor, constant: -8),
                header.heightAnchor.constraint(equalToConstant: 60)
            ])

            // Add footer on the right side
            let footer = LMUIComponents.shared.videoFooterView.init()
            footer.translatesAutoresizingMaskIntoConstraints = false
            footer.backgroundColor = .clear
            footer.contentView.backgroundColor = .clear
            footer.backgroundView = nil
            footer.containerBackgroundColor = .clear
            
            cell.contentView.addSubview(footer)
            NSLayoutConstraint.activate([
                footer.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                footer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16),
                footer.widthAnchor.constraint(equalToConstant: 60),
                footer.heightAnchor.constraint(equalToConstant: 200)
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
    
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let filtered = indexPaths.filter({ $0.item >= data.count - 1 })
        
        if !filtered.isEmpty {
            viewModel?.getFeed()
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.y / scrollView.frame.height)
        if page >= data.count - 1 {
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
}

// MARK: LMFeedPostHeaderViewProtocol, LMFeedPostFooterViewProtocol
extension LMFeedVideoListScreen: LMFeedPostHeaderViewProtocol, LMFeedPostFooterViewProtocol {
    public func didTapPost(postID: String) {
    
    }
    
    public func didTapProfilePicture(having uuid: String) {
        showError(with: "Tapped User Profile having uuid: \(uuid)", isPopVC: false)
    }
    
    public func didTapPostMenuButton(for postID: String) {
        viewModel?.showMenu(for: postID)
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
        do {
            let viewcontroller = try LMFeedLikeViewModel.createModule(postID: postID)
            navigationController?.pushViewController(viewcontroller, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
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
