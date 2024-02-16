//
//  LMFeedPostMediaCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 29/11/23.
//

import AVKit
import UIKit

public protocol LMFeedMediaProtocol { }

@IBDesignable
open class LMFeedPostMediaCell: LMPostWidgetTableViewCell {
    // MARK: Data Model
    public struct ViewModel: LMFeedPostTableCellProtocol {
        public var postID: String
        public var userUUID: String
        public var headerData: LMFeedPostHeaderView.ViewModel
        public var postText: String
        public var isShowMore: Bool
        public var topics: LMFeedTopicView.ViewModel
        public var mediaData: [LMFeedMediaProtocol]
        public var footerData: LMFeedPostFooterView.ViewModel
        public var totalCommentCount: Int
        
        public init(
            postID: String,
            userUUID: String,
            headerData: LMFeedPostHeaderView.ViewModel,
            postText: String,
            topics: LMFeedTopicView.ViewModel,
            mediaData: [LMFeedMediaProtocol],
            footerData: LMFeedPostFooterView.ViewModel,
            totalCommentCount: Int,
            isShowMore: Bool = true
        ) {
            self.postID = postID
            self.userUUID = userUUID
            self.headerData = headerData
            self.postText = postText
            self.topics = topics
            self.mediaData = mediaData
            self.footerData = footerData
            self.totalCommentCount = totalCommentCount
            self.isShowMore = isShowMore
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var mediaCollectionView: LMCollectionView = {
        let collection = LMCollectionView(frame: .zero, collectionViewLayout: LMCollectionView.mediaFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.bounces = false
        collection.backgroundColor = Appearance.shared.colors.clear
        return collection
    }()
    
    open private(set) lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.numberOfPages = mediaCellsData.count
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.pageIndicatorTintColor = .purple
        pageControl.hidesForSinglePage = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    open private(set) lazy var videoPlayer: AVPlayerViewController = {
        let player = AVPlayerViewController()
        player.view.translatesAutoresizingMaskIntoConstraints = false
        player.showsPlaybackControls = true
        return player
    }()
    
    
    //MARK: Data Variables
    private var mediaCellsData: [LMFeedMediaProtocol] = []

    
    // MARK: View Hierachy
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(headerView)
        containerView.addSubview(contentStack)
        containerView.addSubview(footerView)
        containerView.addSubview(postText)
        
        contentStack.addArrangedSubview(topicFeed)
        contentStack.addArrangedSubview(postText)
        contentStack.addArrangedSubview(seeMoreButton)
        contentStack.addArrangedSubview(mediaCollectionView)
        contentStack.addArrangedSubview(pageControl)
    }
    
    // MARK: Constraints
    open override func setupLayouts() {
        super.setupLayouts()
        
        containerView.addConstraint(top: (contentView.topAnchor, 0),
                                    leading: (contentView.leadingAnchor, 0),
                                    trailing: (contentView.trailingAnchor, 0))
        containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        headerView.setHeightConstraint(with: Constants.shared.number.postHeaderSize)
        headerView.addConstraint(
            top: (containerView.topAnchor, 0),
            bottom: (contentStack.topAnchor, -8),
            leading: (containerView.leadingAnchor, 0),
            trailing: (containerView.trailingAnchor, 0)
        )
        
        contentStack.addConstraint(leading: (headerView.leadingAnchor, 0), trailing: (headerView.trailingAnchor, 0))
        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        
        mediaCollectionView.addConstraint(leading: (contentStack.leadingAnchor, 0), trailing: (contentStack.trailingAnchor, 0))
        mediaCollectionView.setHeightConstraint(with: mediaCollectionView.widthAnchor, multiplier: 2/3)
        
        pageControl.addConstraint(leading: (contentStack.leadingAnchor, 0), trailing: (contentStack.trailingAnchor, 0))
        
        footerView.addConstraint(
            top: (contentStack.bottomAnchor, 0),
            bottom: (containerView.bottomAnchor, 0),
            leading: (contentStack.leadingAnchor, 16),
            trailing: (contentStack.trailingAnchor, -16)
        )
        footerView.setHeightConstraint(with: 50)
    }
    
    open override func setupActions() {
        super.setupActions()
        
        headerView.delegate = self
        footerView.delegate = self
        pageControl.addTarget(self, action: #selector(didChangePageControl), for: .primaryActionTriggered)
        
        mediaCollectionView.registerCell(type: LMUIComponents.shared.imagePreviewCell)
        mediaCollectionView.registerCell(type: LMUIComponents.shared.videoPreviewCell)
    }
    
    // MARK: Appearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = Appearance.shared.colors.clear
        contentView.backgroundColor = Appearance.shared.colors.clear
        containerView.backgroundColor = Appearance.shared.colors.white
    }
    
    // MARK: Action
    @objc
    open func didChangePageControl(_ sender: UIPageControl) {
        guard mediaCellsData.indices.contains(sender.currentPage) else { return }
        mediaCollectionView.scrollToItem(at: .init(row: sender.currentPage, section: .zero), at: .centeredHorizontally, animated: true)
    }
    
    open func tableViewScrolled() {
        for case let cell as LMFeedVideoCollectionCell in mediaCollectionView.visibleCells {
            cell.pauseVideo()
        }
    }
    
    // MARK: Configure Function
    open func configure(with data: ViewModel, delegate: LMFeedTableCellToViewControllerProtocol?) {
        actionDelegate = delegate
        postID = data.postID
        userUUID = data.userUUID
        
        headerView.configure(with: data.headerData)
        setupPostText(text: data.postText, showMore: data.isShowMore)
        
        topicFeed.configure(with: data.topics)
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        mediaCellsData = data.mediaData
        setupMediaCells()
        
        footerView.configure(with: data.footerData)
    }
    
    open func setupMediaCells() {
        mediaCollectionView.isHidden = mediaCellsData.isEmpty
        mediaCollectionView.reloadData()
        
        pageControl.isHidden = mediaCellsData.count < 2
        pageControl.numberOfPages = mediaCellsData.count
    }
    
    
    // MARK: Reset Player
    open override func prepareForReuse() {
        super.prepareForReuse()
        tableViewScrolled()
    }
}


//MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
@objc
extension LMFeedPostMediaCell: UICollectionViewDataSource,
                               UICollectionViewDelegate,
                               UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mediaCellsData.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.imagePreviewCell, for: indexPath),
           let data = mediaCellsData[indexPath.row] as? LMFeedImageCollectionCell.ViewModel {
            cell.configure(with: data)
            return cell
        } else if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.videoPreviewCell, for: indexPath),
                  let data = mediaCellsData[indexPath.row] as? LMFeedVideoCollectionCell.ViewModel {
            cell.configure(with: data, videoPlayer: videoPlayer)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? LMFeedVideoCollectionCell else { return }
        cell.pauseVideo()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
}
