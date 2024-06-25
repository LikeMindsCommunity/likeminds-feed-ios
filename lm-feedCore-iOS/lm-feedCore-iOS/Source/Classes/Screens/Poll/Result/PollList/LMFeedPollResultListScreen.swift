//
//  LMFeedPollResultListScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 25/06/24.
//

import LikeMindsFeedUI

open class LMFeedPollResultListScreen: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var voteView: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.register(LMUIComponents.shared.memberItem)
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.separatorStyle = .none
        return table
    }()
    
    open private(set) lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .large
        return indicator
    }()
    
    
    // MARK: Data Variables
    public var userList: [LMFeedMemberItem.ContentModel] = []
    public var viewmodel: LMFeedPollResultListViewModel?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(voteView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.safePinSubView(subView: voteView)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        voteView.backgroundColor = Appearance.shared.colors.clear
        view.backgroundColor = Appearance.shared.colors.clear
    }
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        viewmodel?.fetchUserList()
    }
    
    
    open func onTapUser(with uuid: String) {
        
    }
}


// MARK: TableView
extension LMFeedPollResultListScreen: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userList.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = userList[safe: indexPath.row],
            let cell = tableView.dequeueReusableCell(LMUIComponents.shared.memberItem) {
            cell.configure(with: data) { [weak self] in
                self?.onTapUser(with: data.uuid)
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 72 }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == userList.count - 1 {
            viewmodel?.fetchUserList()
        }
    }
}


// MARK: LMFeedPollResultListViewModelProtocol
extension LMFeedPollResultListScreen: LMFeedPollResultListViewModelProtocol {
    public func reloadResults(with userList: [LMFeedMemberItem.ContentModel]) {
        if userList.isEmpty {
            let vc = LMFeedNoResultView(frame: voteView.bounds)
            vc.translatesAutoresizingMaskIntoConstraints = false
            vc.configure(with: "No Response")
            
            voteView.backgroundView = vc
        } else {
            voteView.backgroundView = nil
        }
        
        self.userList = userList
        voteView.reloadData()
    }
    
    public func showLoader() {
        userList.removeAll(keepingCapacity: true)
        voteView.reloadData()
        
        voteView.backgroundView = indicatorView
        indicatorView.addConstraint(centerX: (voteView.centerXAnchor, 0),
                                    centerY: (voteView.centerYAnchor, 0))
        indicatorView.startAnimating()
    }
    
    public func showHideTableFooter(isShow: Bool) {
        voteView.showHideFooterLoader(isShow: isShow)
    }
}
