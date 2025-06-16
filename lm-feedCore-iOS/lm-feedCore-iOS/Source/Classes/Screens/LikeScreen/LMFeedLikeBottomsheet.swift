import UIKit
import LikeMindsFeedUI

open class LMFeedLikeBottomsheet: LMFeedViewController {
    // MARK: UI Elements
    open private(set) lazy var contentView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    open private(set) lazy var headerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var dragHandlerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.gray155
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    open private(set) lazy var headerTitleLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Liked"
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray1
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var memberListView: LMFeedTableView = {
        let table = LMFeedTableView().translatesAutoresizingMaskIntoConstraints()
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = LMFeedAppearance.shared.colors.clear
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.bounces = false
        table.register(LMUIComponents.shared.memberItem)
        table.separatorStyle = .none
        return table
    }()
    
    open private(set) lazy var noLikedContainerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var noLikedTitleLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LMStringConstants.shared.noLikeTitleLabel
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textAlignment = .center
        return label
    }()
    
    open private(set) lazy var noLikedSubtitleLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LMStringConstants.shared.noLikeSubTitleLabel
        label.textColor = LMFeedAppearance.shared.colors.gray102
        label.font = LMFeedAppearance.shared.fonts.textFont2
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Data Variables
    open private(set) var postID: String
    open private(set) var commentID: String?
    open private(set) var viewModel: LMFeedLikeViewModel!
    open private(set) var userData: [LMFeedMemberItem.ContentModel] = []
    open private(set) var cellHeight: CGFloat = 72
    open private(set) var totalLikes: Int = 0
    
    // MARK: Initialization
    public required init(postID: String, commentID: String? = nil) {
        self.postID = postID
        self.commentID = commentID
        super.init(nibName: nil, bundle: nil)
        self.viewModel = LMFeedLikeViewModel(postID: postID, commentID: commentID, delegate: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        setupActions()
        setupAppearance()
        viewModel.getLikes()
        
        // Analytics
        LMFeedCore.analytics?.trackEvent(for: .postLikeListOpened, eventProperties: ["post_id": postID])
    }
    
    // MARK: Setup Methods
    open override func setupViews() {
        super.setupViews()
        view.addSubview(contentView)
        contentView.addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(memberListView)
        containerView.addSubview(noLikedContainerView)
        
        headerView.addSubview(dragHandlerView)
        headerView.addSubview(headerTitleLabel)
        
        noLikedContainerView.addSubview(noLikedTitleLabel)
        noLikedContainerView.addSubview(noLikedSubtitleLabel)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        // Pin contentView to main view
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Pin containerView to contentView
        contentView.pinSubView(subView: containerView)
        
        // Setup header view constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 72),
            
            // Drag handler constraints
            dragHandlerView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            dragHandlerView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            dragHandlerView.widthAnchor.constraint(equalToConstant: 40),
            dragHandlerView.heightAnchor.constraint(equalToConstant: 5),
            
            // Title label constraints - centered with more spacing from drag handler
            headerTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerTitleLabel.topAnchor.constraint(equalTo: dragHandlerView.bottomAnchor, constant: 16)
        ])
        
        // Setup member list view constraints
        NSLayoutConstraint.activate([
            memberListView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            memberListView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            memberListView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            memberListView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Setup no likes container view constraints
        NSLayoutConstraint.activate([
            noLikedContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            noLikedContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            noLikedContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            noLikedTitleLabel.topAnchor.constraint(equalTo: noLikedContainerView.topAnchor, constant: 16),
            noLikedTitleLabel.centerXAnchor.constraint(equalTo: noLikedContainerView.centerXAnchor),
            
            noLikedSubtitleLabel.topAnchor.constraint(equalTo: noLikedTitleLabel.bottomAnchor, constant: 2),
            noLikedSubtitleLabel.bottomAnchor.constraint(equalTo: noLikedContainerView.bottomAnchor, constant: -16),
            noLikedSubtitleLabel.centerXAnchor.constraint(equalTo: noLikedTitleLabel.centerXAnchor)
        ])
    }
    
    open override func setupActions() {
        super.setupActions()
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = .clear
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    // MARK: Action Methods
    @objc
    open func didTapDismissButton() {
        dismiss(animated: true)
    }
    
    open func didTapUser(uuid: String) {
        print(#function)
    }
}

// MARK: UITableView
extension LMFeedLikeBottomsheet: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userData.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = userData[safe: indexPath.row],
           let cell = tableView.dequeueReusableCell(LMUIComponents.shared.memberItem) {
            cell.configure(with: data) { [weak self] in
                self?.didTapUser(uuid: data.uuid)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == userData.count - 1 {
            viewModel.getLikes()
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { cellHeight }
}

// MARK: LMFeedLikeViewModelProtocol
extension LMFeedLikeBottomsheet: LMFeedLikeViewModelProtocol {
    public func reloadTableView(with data: [LMFeedMemberItem.ContentModel], totalCount: Int) {
        userData = data
        UIView.performWithoutAnimation {
            memberListView.reloadData()
        }
        totalLikes = totalCount
        
        // Show/hide no likes view based on data count
        noLikedContainerView.isHidden = !userData.isEmpty
        memberListView.isHidden = userData.isEmpty
    }
    
    public func showHideTableLoader(isShow: Bool) {
        memberListView.showHideFooterLoader(isShow: isShow)
    }
} 
