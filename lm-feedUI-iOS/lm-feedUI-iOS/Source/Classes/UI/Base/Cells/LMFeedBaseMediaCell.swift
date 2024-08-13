//
//  LMFeedBaseMediaCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 23/07/24.
//

import UIKit

open class LMFeedBaseMediaCell: LMPostWidgetTableViewCell {
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
        collection.backgroundColor = LMFeedAppearance.shared.colors.clear
        collection.registerCell(type: LMUIComponents.shared.imagePreview)
        collection.registerCell(type: LMUIComponents.shared.videoPreview)
        return collection
    }()
    
    open private(set) lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.numberOfPages = mediaCellsData.count
        pageControl.currentPageIndicatorTintColor = LMFeedAppearance.shared.colors.appTintColor
        pageControl.pageIndicatorTintColor = LMFeedAppearance.shared.colors.gray155
        pageControl.hidesForSinglePage = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    
    //MARK: Data Variables
    public var mediaCellsData: [LMFeedMediaProtocol] = []
    public weak var delegate: LMFeedPostMediaCellProtocol?
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = LMFeedAppearance.shared.colors.clear
        contentView.backgroundColor = LMFeedAppearance.shared.colors.clear
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        pageControl.addTarget(self, action: #selector(didChangePageControl), for: .primaryActionTriggered)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        mediaCollectionView.setWidthConstraint(with: contentStack.widthAnchor)
        mediaCollectionView.setHeightConstraint(with: contentStack.widthAnchor)
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
    open func configure(with data: LMFeedPostContentModel, delegate: LMFeedPostMediaCellProtocol?) {
        actionDelegate = delegate
        self.delegate = delegate
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
extension LMFeedBaseMediaCell: UICollectionViewDataSource,
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
            cell.configure(with: data, index: indexPath.row)
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
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let postID else { return }
        delegate?.didTapMedia(postID: postID, index: indexPath.row)
        
    }
    
    public func scrollingFinished() {
        pageControl.currentPage = Int(mediaCollectionView.contentOffset.x / mediaCollectionView.frame.width)
        
        if mediaCollectionView.visibleCells.count == 1 {
            (mediaCollectionView.visibleCells.first as? LMFeedVideoCollectionCell)?.playVideo()
        }
    }
}
