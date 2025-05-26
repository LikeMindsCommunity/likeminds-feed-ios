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
    
    // MARK: Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        setupActions()
        setupAppearance()
        
        viewModel?.getFeed()
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
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching
extension LMFeedVideoListScreen: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.pageColors.count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        // Remove any existing subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        if let color = viewModel?.pageColors[safe: indexPath.item] {
            cell.backgroundColor = color
            
            // Add a label to show the color name
            let label = UILabel()
            label.text = "Page \(indexPath.item + 1)"
            label.textColor = .white
            label.font = .systemFont(ofSize: 24, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            // Add header
            let header = LMFeedPostHeaderView()
            header.translatesAutoresizingMaskIntoConstraints = false
            header.backgroundColor = .clear
            header.contentView.backgroundColor = .clear
            header.backgroundView = nil
            header.containerBackgroundColor = .clear
            
            cell.contentView.addSubview(header)
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                header.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -276),
                header.widthAnchor.constraint(equalToConstant: 200),
                header.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            
            // Add footer
            let footer = LMFeedPostFooterView()
            footer.translatesAutoresizingMaskIntoConstraints = false
            footer.orientation = .vertical
            footer.backgroundColor = .clear
            footer.contentView.backgroundColor = .clear
            footer.containerBackgroundColor = .clear
            footer.backgroundView = nil
            
            cell.contentView.addSubview(footer)
            NSLayoutConstraint.activate([
                footer.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                footer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16),
                footer.widthAnchor.constraint(equalToConstant: 60),
                footer.heightAnchor.constraint(equalToConstant: 200)
            ])
            
            // Configure header
            let headerData = LMFeedPostHeaderView.ContentModel(
                profileImage: nil,
                authorName: "User \(indexPath.item + 1)",
                authorTag: "Creator",
                subtitle: "2d ago",
                isPinned: false,
                showMenu: false,
                widgets: nil
            )
            header.configure(with: headerData, postID: "page_\(indexPath.item)", userUUID: "user_\(indexPath.item)", delegate: self)
            
            // Configure footer
            let footerData = LMFeedPostFooterView.ContentModel(
                isSaved: false,
                isLiked: false,
                likeCount: 0,
                commentCount: 0,
                likeText: "Like",
                commentText: "Comment",
                user: nil,
                widgets: nil
            )
            footer.configure(with: footerData, topResponse: nil, postID: "page_\(indexPath.item)", delegate: self, orientation: .vertical)
        }
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Handle prefetching if needed
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
        reloadCollectionView()
        delegate?.onPostDataFetched(isEmpty: false)
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
    
    public func didTapLikeButton(for postID: String) {
        if let index = viewModel?.pageColors.firstIndex(where: { _ in true }) {
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
        guard let viewController = LMFeedPostDetailViewModel.createModule(for: postID, openCommentSection: true) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    public func didTapShareButton(for postID: String) {
        LMFeedShareUtility.sharePost(from: self, postID: postID)
    }
    
    public func didTapSaveButton(for postID: String) {
        viewModel?.savePost(for: postID)
    }
}
