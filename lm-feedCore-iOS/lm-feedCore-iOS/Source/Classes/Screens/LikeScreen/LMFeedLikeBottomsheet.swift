import UIKit
import LikeMindsFeedUI

open class LMFeedLikeBottomsheet: LMFeedViewController {
    // MARK: UI Elements
    private lazy var contentView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var containerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var headerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        return view
    }()
    
    private lazy var dragHandlerView: LMFeedView = {
        let view = LMFeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = LMFeedAppearance.shared.colors.gray155
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var headerTitleLabel: LMFeedLabel = {
        let label = LMFeedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Liked"
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray1
        label.textAlignment = .center
        return label
    }()
    
    
    private lazy var memberListView: LMFeedTableView = {
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
    
    // MARK: Data Variables
    private var postID: String
    private var commentID: String?
    private var viewModel: LMFeedLikeViewModel!
    private var userData: [LMFeedMemberItem.ContentModel] = []
    private var cellHeight: CGFloat = 72
    private var totalLikes: Int = 0
    
    // MARK: Initialization
    public init(postID: String, commentID: String? = nil) {
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
        
        headerView.addSubview(dragHandlerView)
        headerView.addSubview(headerTitleLabel)
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
    @objc private func didTapDismissButton() {
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
    }
    
    public func showHideTableLoader(isShow: Bool) {
        memberListView.showHideFooterLoader(isShow: isShow)
    }
} 
