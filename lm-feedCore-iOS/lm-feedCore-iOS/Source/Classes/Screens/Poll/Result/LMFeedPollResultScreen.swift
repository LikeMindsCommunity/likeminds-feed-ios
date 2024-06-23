//
//  LMFeedPollResultScreen.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 17/06/24.
//

import LikeMindsFeedUI
import UIKit

open class LMFeedPollResultScreen: LMViewController {
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var optionView: LMCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collection = LMCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.registerCell(type: LMFeedPollResultCollectionCell.self)
        collection.dataSource = self
        collection.delegate = self
        collection.bounces = false
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
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
    public var optionList: [LMFeedPollResultCollectionCell.ContentModel] = []
    public var viewmodel: LMFeedPollResultViewModel?
    
    
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        containerView.addSubview(optionView)
        containerView.addSubview(voteView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.safePinSubView(subView: containerView)
        
        optionView.addConstraint(top: (containerView.topAnchor, 0),
                                 leading: (containerView.leadingAnchor, 16),
                                 trailing: (containerView.trailingAnchor, -16))
        optionView.setHeightConstraint(with: 72)
        
        voteView.addConstraint(top: (optionView.bottomAnchor, 8),
                               bottom: (containerView.bottomAnchor, 0),
                               leading: (containerView.leadingAnchor, 0),
                               trailing: (containerView.trailingAnchor, 0))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = Appearance.shared.colors.white
        optionView.backgroundColor = Appearance.shared.colors.clear
        voteView.backgroundColor = Appearance.shared.colors.clear
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitleAndSubtitle(with: "Poll Results", subtitle: nil, alignment: .center)
        viewmodel?.initializeView()
    }
    
    // MARK: Actions
    open func onTapUser(with uuid: String) { }
}

extension LMFeedPollResultScreen: UITableViewDataSource, UITableViewDelegate {
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


extension LMFeedPollResultScreen: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        optionList.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let data = optionList[safe: indexPath.row],
           let cell = collectionView.dequeueReusableCell(with: LMFeedPollResultCollectionCell.self, for: indexPath) {
            cell.configure(with: data)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = optionList.count
        
        if count < 3 {
            return .init(width: collectionView.frame.width / CGFloat(count), height: collectionView.frame.height)
        } else {
            return .init(width: collectionView.frame.width * 0.3, height: collectionView.frame.height)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = optionList[safe: indexPath.row] else { return }
        
        let count = optionList.count
        
        for i in 0..<count {
            optionList[i].isSelected = indexPath.row == i
        }
        
        collectionView.reloadData()
        viewmodel?.fetchUserList(for: item.optionID)
    }
}


// MARK: LMFeedPollResultViewModelProtocol
extension LMFeedPollResultScreen: LMFeedPollResultViewModelProtocol {
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
    
    public func reloadResults(with userList: [LikeMindsFeedUI.LMFeedMemberItem.ContentModel]) {
        showHideTableFooter(isShow: false)
        
        guard !userList.isEmpty else {
            let bgView = LMFeedNoResultView(frame: voteView.bounds)
            bgView.configure(with: "No Responses")
            voteView.backgroundView = bgView
            return
        }
        
        self.userList = userList
        voteView.backgroundView = nil
        voteView.reloadData()
    }
    
    public func loadOptionList(with data: [LMFeedPollResultCollectionCell.ContentModel], index: Int) {
        self.optionList = data
        optionView.reloadData()
        
        DispatchQueue.main.async { [weak optionView] in
            optionView?.scrollToItem(at: .init(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}
