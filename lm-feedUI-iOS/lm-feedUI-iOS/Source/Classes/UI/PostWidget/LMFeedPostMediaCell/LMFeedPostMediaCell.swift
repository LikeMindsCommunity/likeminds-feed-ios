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
    public struct ContentModel: LMFeedPostTableCellProtocol {
        public var postID: String
        public var userUUID: String
        public var headerData: LMFeedPostHeaderView.ContentModel
        public var postText: String
        public var isShowMore: Bool
        public var topics: LMFeedTopicView.ContentModel
        public var mediaData: [LMFeedMediaProtocol]
        public var footerData: LMFeedPostFooterView.ContentModel
        public var totalCommentCount: Int
        
        public init(
            postID: String,
            userUUID: String,
            headerData: LMFeedPostHeaderView.ContentModel,
            postText: String,
            topics: LMFeedTopicView.ContentModel,
            mediaData: [LMFeedMediaProtocol],
            footerData: LMFeedPostFooterView.ContentModel,
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
        collection.registerCell(type: LMUIComponents.shared.imagePreview)
        collection.registerCell(type: LMUIComponents.shared.videoPreview)
        return collection
    }()
    
    open private(set) lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.numberOfPages = mediaCellsData.count
        pageControl.currentPageIndicatorTintColor = Appearance.shared.colors.appTintColor
        pageControl.pageIndicatorTintColor = Appearance.shared.colors.gray155
        pageControl.hidesForSinglePage = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    
    //MARK: Data Variables
    private var mediaCellsData: [LMFeedMediaProtocol] = []
    
    deinit { }
    
    open override func prepareForReuse() {
        print("Media Cell is Dequeued")
        tableViewScrolled()
        super.prepareForReuse()
    }
    

    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(contentStack)
        containerView.addSubview(postText)
        
        contentStack.addArrangedSubview(topicFeed)
        contentStack.addArrangedSubview(postText)
        contentStack.addArrangedSubview(seeMoreButton)
        contentStack.addArrangedSubview(mediaCollectionView)
        contentStack.addArrangedSubview(pageControl)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        contentView.pinSubView(subView: containerView)
        containerView.pinSubView(subView: contentStack)
        
        topicFeed.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        postText.addConstraint(leading: (contentStack.leadingAnchor, 16), trailing: (contentStack.trailingAnchor, -16))
        
        mediaCollectionView.setWidthConstraint(with: contentStack.widthAnchor)
        mediaCollectionView.setHeightConstraint(with: mediaCollectionView.widthAnchor, multiplier: 2/3)
        
        pageControl.addConstraint(leading: (contentStack.leadingAnchor, 0), trailing: (contentStack.trailingAnchor, 0))
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = Appearance.shared.colors.clear
        contentView.backgroundColor = Appearance.shared.colors.clear
        containerView.backgroundColor = Appearance.shared.colors.white
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        pageControl.addTarget(self, action: #selector(didChangePageControl), for: .primaryActionTriggered)
    }
    
    @objc
    open func didChangePageControl(_ sender: UIPageControl) {
        guard mediaCellsData.indices.contains(sender.currentPage) else { return }
        mediaCollectionView.scrollToItem(at: .init(row: sender.currentPage, section: .zero), at: .centeredHorizontally, animated: true)
    }
    
    open func tableViewScrolled(isPlay: Bool = false) {
        for case let cell as LMFeedVideoCollectionCell in mediaCollectionView.visibleCells {
            cell.pauseVideo()
        }
        
        if isPlay,
           mediaCollectionView.indexPathsForFullyVisibleItems().count == 1,
           let visibleIndex = mediaCollectionView.indexPathsForFullyVisibleItems().first {
            (mediaCollectionView.cellForItem(at: visibleIndex) as? LMFeedVideoCollectionCell)?.playVideo()
        }
    }
    
    
    // MARK: Configure Function
    open func configure(with data: ContentModel, delegate: LMPostWidgetTableViewCellProtocol?) {
        actionDelegate = delegate
        postID = data.postID
        userUUID = data.userUUID
        
        setupPostText(text: data.postText, showMore: data.isShowMore)
        topicFeed.configure(with: data.topics)
        
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        mediaCellsData = data.mediaData
        setupMediaCells()
    }
    
    open func setupMediaCells() {
        mediaCollectionView.isHidden = mediaCellsData.isEmpty
        mediaCollectionView.reloadData()
        
        pageControl.isHidden = mediaCellsData.count < 2
        pageControl.numberOfPages = mediaCellsData.count
        
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
        if let data = mediaCellsData[indexPath.row] as? LMFeedImageCollectionCell.ContentModel,
           let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.imagePreview, for: indexPath) {
            cell.configure(with: data)
            return cell
        } else if let data = mediaCellsData[indexPath.row] as? LMFeedVideoCollectionCell.ContentModel,
                  let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.videoPreview, for: indexPath) {
            cell.configure(with: data)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingFinished()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollingFinished()
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableViewScrolled()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? LMFeedVideoCollectionCell)?.pauseVideo()
    }
    
    public func scrollingFinished() {
        pageControl.currentPage = Int(mediaCollectionView.contentOffset.x / mediaCollectionView.frame.width)
        
        if mediaCollectionView.visibleCells.count == 1 {
            (mediaCollectionView.visibleCells.first as? LMFeedVideoCollectionCell)?.playVideo()
        }
    }
}
